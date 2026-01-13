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


# Константы
BINARY_PATH = Path.home() / ".local" / "bin" / "operator-tui-waybar"
SCRIPT_DIR = Path(__file__).parent.resolve()

# Переменные окружения
NATS_URL = "nats://10.10.13.125:25222"
NATS_CREDS_FILE = (
    Path.home() / ".config" / "nats" / "context" / "astral-prod-apps.creds"
)


def error_json(message: str) -> None:
    """Выводит ошибку в формате JSON."""
    result = {"text": "Ошибка", "tooltip": message, "class": "error"}
    print(json.dumps(result, ensure_ascii=False))
    sys.exit(1)


def find_binary() -> Path | None:
    """Ищет бинарник operator-tui-waybar."""
    # Проверяем основной путь
    if BINARY_PATH.exists() and os.access(BINARY_PATH, os.X_OK):
        return BINARY_PATH

    # Пробуем найти в директории проекта
    project_root = SCRIPT_DIR.parent
    binary_path = project_root / "bin" / "operator-tui-waybar"

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


def format_queues_output(raw_output: str) -> dict:
    """Парсит и форматирует вывод бинарника."""
    try:
        data = json.loads(raw_output)
    except json.JSONDecodeError:
        error_json("Бинарник вернул невалидный JSON")

    tooltip = data.get("tooltip", "")

    # Извлекаем значения очередей из tooltip
    incoming_match = re.search(r"Incoming: (\d+)", tooltip)
    reader_match = re.search(r"Reader: (\d+)", tooltip)
    writer_match = re.search(r"Writer: (\d+)", tooltip)
    packer_match = re.search(r"Packer: (\d+)", tooltip)
    sender_match = re.search(r"Sender: (\d+)", tooltip)
    total_match = re.search(r"Всего: (\d+)", tooltip)

    # Получаем значения
    incoming_val = int(incoming_match.group(1)) if incoming_match else 0
    reader_val = int(reader_match.group(1)) if reader_match else 0
    writer_val = int(writer_match.group(1)) if writer_match else 0
    packer_val = int(packer_match.group(1)) if packer_match else 0
    sender_val = int(sender_match.group(1)) if sender_match else 0
    total_val = int(total_match.group(1)) if total_match else 0

    # Определяем класс и цвет для каждой очереди
    _, incoming_color = get_queue_class(incoming_val)
    _, reader_color = get_queue_class(reader_val)
    _, writer_color = get_queue_class(writer_val)
    _, packer_color = get_queue_class(packer_val)
    _, sender_color = get_queue_class(sender_val)
    total_class, total_color = get_queue_class(total_val)

    # Форматируем текст с HTML-разметкой для каждой очереди
    text_parts = [
        f'<span foreground="{incoming_color}">I:{incoming_val}</span>',
        f'<span foreground="{reader_color}">R:{reader_val}</span>',
        f'<span foreground="{writer_color}">W:{writer_val}</span>',
        f'<span foreground="{packer_color}">P:{packer_val}</span>',
        f'<span foreground="{sender_color}">S:{sender_val}</span>',
        f'<span foreground="{total_color}">T:{total_val}</span>',
    ]
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
