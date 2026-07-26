#!/usr/bin/env bash

URL="https://live.vkvideo.ru/experience_game"
APP_ID="float-mpv"
STATE_FILE="/tmp/mpv-niri-state.json"

# получить id окна mpv
WIN_JSON=$(niri msg -j windows)
WIN_ID=$(echo "$WIN_JSON" | jq -r ".[] | select(.app_id==\"$APP_ID\") | .id")

# если не запущено → запуск
if [ -z "$WIN_ID" ]; then
  mpv \
    --input-ipc-server=/tmp/mpv-socket \
    --geometry=50%:50% \
    --autofit=800x450 \
    "$URL" &
  exit 0
fi

# текущий workspace
CURRENT_WS=$(niri msg -j workspaces | jq '.[] | select(.focused).id')

# workspace окна
WINDOW_WS=$(echo "$WIN_JSON" | jq -r ".[] | select(.id==$WIN_ID) | .workspace_id")

# координаты окна
X=$(echo "$WIN_JSON" | jq -r ".[] | select(.id==$WIN_ID) | .floating_position.x")
Y=$(echo "$WIN_JSON" | jq -r ".[] | select(.id==$WIN_ID) | .floating_position.y")

# если окно на текущем workspace → прячем
if [ "$CURRENT_WS" = "$WINDOW_WS" ]; then
  # сохранить позицию
  echo "{\"x\":$X,\"y\":$Y}" >"$STATE_FILE"

  # пауза
  echo "set pause yes" | socat - /tmp/mpv-socket 2>/dev/null

  # спрятать
  niri msg action move-window-to-workspace --id "$WIN_ID" 9

else
  # вернуть
  niri msg action move-window-to-workspace --id "$WIN_ID" "$CURRENT_WS"
  niri msg action focus-window --id "$WIN_ID"

  # восстановить позицию
  if [ -f "$STATE_FILE" ]; then
    X=$(jq .x "$STATE_FILE")
    Y=$(jq .y "$STATE_FILE")
    niri msg action move-floating-window --id "$WIN_ID" -x "$X" -y "$Y"
  fi

  # снять паузу
  echo "set pause no" | socat - /tmp/mpv-socket 2>/dev/null
fi
