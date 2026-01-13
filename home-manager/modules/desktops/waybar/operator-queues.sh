#!/run/current-system/sw/bin/bash

# Скрипт для waybar, который выводит информацию о состоянии очередей
# Убедитесь, что путь к бинарнику правильный

# Путь к скомпилированному бинарнику (можно изменить)
BINARY_PATH="${HOME}/.local/bin/operator-tui-waybar"

# Если бинарник не найден, попробуем найти его в текущей директории проекта
if [ ! -f "$BINARY_PATH" ]; then
	SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
	BINARY_PATH="${PROJECT_ROOT}/bin/operator-tui-waybar"
fi

# Если бинарник все еще не найден, попробуем использовать go run (для разработки)
if [ ! -f "$BINARY_PATH" ]; then
	SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
	if [ -d "$PROJECT_ROOT" ]; then
		cd "$PROJECT_ROOT" || exit 1
		go run ./cmd/waybar
	else
		echo '{"text": "Ошибка", "tooltip": "Бинарник не найден", "class": "error"}'
		exit 1
	fi
else
	exec "$BINARY_PATH"
fi
