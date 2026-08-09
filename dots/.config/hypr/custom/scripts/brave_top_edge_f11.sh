#!/usr/bin/env bash

# Toggles Brave fullscreen: sends F11 immediately, then watches for a 3s dwell at the top strip to send F11 again.

set -u

TARGET_CLASS="brave-browser"
TOP_BAND_PX=50
DWELL_MS=3000
DWELL_SECONDS=$((DWELL_MS / 1000))
POLL_INTERVAL=0.1

dwell_start_ms=0

command -v hyprctl >/dev/null 2>&1 || {
  echo "hyprctl is required" >&2
  exit 1
}
command -v jq >/dev/null 2>&1 || {
  echo "jq is required" >&2
  exit 1
}

now_ms() {
  date +%s%3N
}

brave_exists() {
  hyprctl -j clients 2>/dev/null | jq -e 'any(.[]; (.class // "" | ascii_downcase) as $c | ($c=="brave-browser" or $c=="brave"))' >/dev/null
}

get_cursor_pos() {
  local cursor
  if cursor=$(hyprctl -j cursorpos 2>/dev/null); then
    jq -r '"\(.x) \(.y)"' <<<"$cursor"
    return 0
  fi

  if cursor=$(hyprctl cursorpos 2>/dev/null); then
    local parsed
    parsed=$(grep -oE '-?[0-9]+' <<<"$cursor" | head -n 2 | tr '\n' ' ')
    if [[ -n "$parsed" ]]; then
      read -r cx cy <<<"$parsed"
      echo "$cx $cy"
      return 0
    fi
  fi

  return 1
}

send_f11() {
  # Try native Hyprland shortcut dispatch first.
  if hyprctl dispatch sendshortcut "" F11 activewindow >/dev/null 2>&1; then
    return 0
  fi

  # Fallback: send the key via wtype if available.
  if command -v wtype >/dev/null 2>&1; then
    if wtype -k F11 >/dev/null 2>&1; then
      return 0
    fi
  fi

  # Fallback: send the key via ydotool if available.
  if command -v ydotool >/dev/null 2>&1; then
    # KEY_F11 is 87 in Linux input-event codes.
    if ydotool key 87 >/dev/null 2>&1; then
      return 0
    fi
  fi

  echo "Failed to send F11" >&2
  return 1
}

if ! brave_exists; then
  exit 0
fi

send_f11

while brave_exists; do
  sleep "$POLL_INTERVAL"

  active_json=$(hyprctl -j activewindow 2>/dev/null) || {
    dwell_start_ms=0
    continue
  }
  [[ -n "$active_json" && "$active_json" != "null" ]] || {
    dwell_start_ms=0
    continue
  }

  class=$(jq -r '.class // empty' <<<"$active_json") || {
    dwell_start_ms=0
    continue
  }
  class_lc=${class,,}
  case "$class_lc" in
  "$TARGET_CLASS" | brave) ;;
  *)
    dwell_start_ms=0
    continue
    ;;
  esac

  read -r win_x win_y win_w win_h <<<"$(jq -r '"\(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"' <<<"$active_json")" || {
    dwell_start_ms=0
    continue
  }

  if ! read -r cursor_x cursor_y <<<"$(get_cursor_pos)"; then
    dwell_start_ms=0
    continue
  fi

  if ((cursor_x >= win_x && cursor_x <= win_x + win_w && cursor_y >= win_y && cursor_y <= win_y + win_h && cursor_y - win_y < TOP_BAND_PX)); then
    if ((dwell_start_ms == 0)); then
      dwell_start_ms=$(now_ms)
      continue
    fi

    if (($(now_ms) - dwell_start_ms >= DWELL_MS)); then
      send_f11
      exit 0
    fi
  else
    dwell_start_ms=0
  fi
done

exit 0
