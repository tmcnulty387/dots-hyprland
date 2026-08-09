#!/usr/bin/env bash
set -euo pipefail

# Cycle through workspaces on the active monitor that currently have windows, skipping the special scratchpad.

active_workspace_json="$(hyprctl activeworkspace -j)"
current_workspace="$(jq -r '.id' <<<"$active_workspace_json")"
active_monitor_id="$(jq -r '.monitorID' <<<"$active_workspace_json")"
mapfile -t active_workspaces < <(
  hyprctl workspaces -j \
    | jq -r --argjson mon "$active_monitor_id" '
        map(select(.id != -99 and .name != "special" and .windows > 0 and .monitorID == $mon))
        | sort_by(.id) | .[].id'
)

# Nothing to cycle through.
if [[ ${#active_workspaces[@]} -eq 0 ]]; then
  exit 0
fi

next_workspace="${active_workspaces[0]}"
for i in "${!active_workspaces[@]}"; do
  if [[ "${active_workspaces[$i]}" == "${current_workspace}" ]]; then
    next_workspace="${active_workspaces[$(( (i + 1) % ${#active_workspaces[@]} ))]}"
    break
  fi
done

hyprctl dispatch workspace "${next_workspace}"
