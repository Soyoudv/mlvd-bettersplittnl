#!/usr/bin/env bash

EXCLUDED_APPS="./excluded-apps"
echo "Using excluded apps list from: $EXCLUDED_APPS"

#read excluded apps into array
mapfile -t EXCLUDED_APPS < "$EXCLUDED_APPS"

STATE_FILE="$HOME/.cache/mullvad-split-pids"
echo "Started using state file: $STATE_FILE"

#ensure state file directory exists
mkdir -p "$(dirname "$STATE_FILE")"

#reset state file
: > "$STATE_FILE" # : because > alone can fail if noclobber is set

while true; do
  for app in "${EXCLUDED_APPS[@]}"; do
    pgrep -f "$app" | while read -r pid; do
      if ! grep -q "^$pid$" "$STATE_FILE"; then
        echo -e "\e[31m$app\e[0m [$pid]"
        if mullvad split-tunnel add "$pid"; then
          echo "$pid" >> "$STATE_FILE"
        else 
          echo "Failed to add $app [$pid] to split tunnel"
        fi
      fi
    done
  done
  
  sleep 5
done

