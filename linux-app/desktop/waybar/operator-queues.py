#!/usr/bin/env python3
"""
Скрипт для waybar, который выводит информацию о состоянии очередей оператора.
Парсит вывод бинарника и форматирует его для отображения всех очередей на панели.
"""

import json
import os
import re
import subprocess
import sys
from pathlib import Path

# Общие префиксы имён стримов, которые можно отбросить при построении короткой метки.
STRIP_PREFIXES = (
    "operator-internal-roseu-",
    "operator-internal-",
    "edicore-",
    "operator-",
)

# Названия всех очередей (ключи — исходные имена стримов из бинарника).
# Значения — отображаемые метки; оставьте пустой строкой, чтобы использовать
# автоматическую короткую метку (short_label). Порядок в этом словаре
# определяет порядок отображения очередей на панели.
QUEUE_LABELS: dict[str, str] = {
    "edicore-message-process": "message-process",
    "operator-internal-roseu-reader": "roseu-reader",
    "operator-internal-roseu-writer": "roseu-writer",
    "operator-internal-roseu-packer": "roseu-packer",
    "edicore-pack": "package-creator",
    "operator-internal-roseu-sender": "roseu-sender",
    "edicore-send": "package-sender",
    "edicore-marking": "marking",
    "edicore-rnpt": "rnpt",
    "edicore-storage": "storage",
    "operator-internal-edi-docs": "edi-pdp",
    "operator-internal-edi-rnpt": "edi-rnpt",
    "operator-internal-edi-sender": "edi-sender",
}

# Константы
BINARY_PATH = Path.home() / ".local" / "bin" / "operator-tui-waybar"
SCRIPT_DIR = Path(__file__).parent.resolve()
SECRETS_FILE = Path.home() / ".config" / "waybar" / "secrets.json"
RUN_SECRETS = Path("/run/secrets")


def read_secret(name: str) -> str | None:
    secret_path = RUN_SECRETS / name
    if secret_path.exists():
        return secret_path.read_text(encoding="utf-8").strip()
    return None


def load_waybar_secrets() -> dict:
    defaults = {
        "nats_url": "nats://127.0.0.1:4222",
        "nats_creds_file": str(
            Path.home() / ".config" / "nats" / "context" / "default.creds"
        ),
    }
    if SECRETS_FILE.exists():
        with open(SECRETS_FILE, encoding="utf-8") as handle:
            data = json.load(handle)
        defaults.update(data)

    nats_url = read_secret("waybar_nats_url")
    if nats_url:
        defaults["nats_url"] = nats_url

    nats_creds = read_secret("waybar_nats_creds_file")
    if nats_creds:
        defaults["nats_creds_file"] = nats_creds

    return defaults


WAYBAR_SECRETS = load_waybar_secrets()
NATS_URL = WAYBAR_SECRETS["nats_url"]
NATS_CREDS_FILE = Path(WAYBAR_SECRETS["nats_creds_file"])


def error_json(message: str) -> None:
    """Выводит ошибку в формате JSON."""
    result = {"text": "Ошибка", "tooltip": message, "class": "error"}
    print(json.dumps(result, ensure_ascii=False))
    sys.exit(1)


def find_binary() -> Path | None:
    """Ищет бинарник operator-tui-waybar."""
    candidates = [
        BINARY_PATH,
        Path.home() / ".local" / "bin" / "operator-tui-waybar",
        Path("/etc/profiles/per-user")
        / Path.home().name
        / "bin"
        / "operator-tui-waybar",
    ]
    # SCRIPT_DIR may be a nix store symlink; also check sibling project layouts.
    for root in (SCRIPT_DIR.parent, Path.home() / "Dev"):
        candidates.append(root / "bin" / "operator-tui-waybar")

    for binary_path in candidates:
        if binary_path.exists() and os.access(binary_path, os.X_OK):
            return binary_path

    return None


def get_queue_class(value: int) -> tuple[str, str]:
    """
    Определяет класс и цвет для очереди на основе количества сообщений.
    Возвращает (класс, цвет).
    """
    if value <= 10000:
        return ("normal", "#40a02b")  # green
    elif value <= 20000:
        return ("warning", "#fe640b")  # peach/orange
    else:
        return ("critical", "#d20f39")  # red


def short_label(name: str) -> str:
    """Строит короткую метку очереди, отбрасывая общие префиксы имён стримов."""
    label = name
    for prefix in STRIP_PREFIXES:
        if label.startswith(prefix):
            label = label[len(prefix) :]
            break
    return label or name


def format_queues_output(raw_output: str) -> dict:
    """Парсит и форматирует вывод бинарника."""
    try:
        data = json.loads(raw_output)
    except json.JSONDecodeError:
        error_json("Бинарник вернул невалидный JSON")

    tooltip = data.get("tooltip", "")

    # Динамически извлекаем очереди из tooltip: каждая строка вида "<имя>: N".
    # Жадный захват имени с конца строки позволяет корректно обрабатывать
    # имена, содержащие двоеточие.
    queues = []
    total_val = 0
    total_seen = False
    for line in tooltip.splitlines():
        match = re.match(r"^(.*): (\d+)$", line.strip())
        if not match:
            continue
        name, value_str = match.groups()
        value = int(value_str)
        if name == "Всего":
            total_val = value
            total_seen = True
        else:
            queues.append((name, value))

    # Если строка "Всего" отсутствует, считаем сумму по всем очередям.
    if not total_seen:
        total_val = sum(value for _, value in queues)

    # Показываем только те очереди, которые перечислены в QUEUE_LABELS,
    # в порядке, заданном в словаре, и только если их количество > 10000.
    # Неизвестные очереди не отображаются.
    MIN_QUEUE_VALUE = 10000
    known = {name: value for name, value in queues if name in QUEUE_LABELS}
    ordered = [
        (name, known[name])
        for name in QUEUE_LABELS
        if name in known and known[name] > MIN_QUEUE_VALUE
    ]

    def label_of(name: str) -> str:
        return QUEUE_LABELS.get(name) or short_label(name)

    # Определяем цвет для каждой очереди и собираем текст панели.
    text_parts = []
    for name, value in ordered:
        _, color = get_queue_class(value)
        text_parts.append(f'<span foreground="{color}">{label_of(name)}:{value}</span>')

    total_class, total_color = get_queue_class(total_val)
    text_parts.append(f'<span foreground="{total_color}">T:{total_val}</span>')

    text = " ".join(text_parts)

    # Используем класс для общего модуля на основе total
    class_val = total_class

    return {"text": text, "tooltip": tooltip, "class": class_val}


def run_binary(binary_path: Path) -> str:
    """Запускает бинарник и возвращает его вывод."""
    env = os.environ.copy()
    env["NATS_URL"] = NATS_URL
    env["NATS_CREDS_FILE"] = str(NATS_CREDS_FILE)

    try:
        result = subprocess.run(
            [str(binary_path)], capture_output=True, text=True, env=env, timeout=5
        )

        if result.returncode != 0:
            error_json(f"Ошибка выполнения бинарника (код: {result.returncode})")

        if not result.stdout.strip():
            error_json("Бинарник вернул пустой вывод")

        return result.stdout.strip()

    except subprocess.TimeoutExpired:
        error_json("Таймаут выполнения бинарника")
    except FileNotFoundError:
        error_json("Бинарник не найден")
    except Exception as e:
        error_json(f"Ошибка выполнения бинарника: {str(e)}")


def run_go_dev() -> str:
    """Запускает go run для разработки."""
    project_root = SCRIPT_DIR.parent

    if not project_root.exists():
        error_json("Директория проекта не найдена")

    try:
        result = subprocess.run(
            ["go", "run", "./cmd/waybar"],
            cwd=project_root,
            capture_output=True,
            text=True,
            timeout=10,
        )

        if result.returncode != 0:
            error_json(f"Ошибка выполнения go run: {result.stderr}")

        if not result.stdout.strip():
            error_json("go run вернул пустой вывод")

        return result.stdout.strip()

    except subprocess.TimeoutExpired:
        error_json("Таймаут выполнения go run")
    except FileNotFoundError:
        error_json("Go не установлен")
    except Exception as e:
        error_json(f"Ошибка выполнения go run: {str(e)}")


def main():
    """Основная функция."""
    # Ищем бинарник
    binary_path = find_binary()

    if binary_path:
        # Запускаем бинарник
        output = run_binary(binary_path)
    else:
        # Пробуем использовать go run для разработки
        output = run_go_dev()

    # Проверяем, что вывод начинается с {
    if not output.startswith("{"):
        error_json("Бинарник вернул невалидный JSON")

    # Форматируем и выводим
    result = format_queues_output(output)
    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
