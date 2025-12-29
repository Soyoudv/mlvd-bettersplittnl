#!/usr/bin/env bash

#reset log
: > ./out.log

EXCLUDED_APPS="./excluded-apps"
echo "Using excluded apps list from: $EXCLUDED_APPS"

#read excluded apps into array
mapfile -t EXCLUDED_APPS < "$EXCLUDED_APPS"

STATE_FILE="$HOME/.cache/mullvad-split-pids"

#ensure state file directory exists
mkdir -p "$(dirname "$STATE_FILE")"

#reset state file
: > "$STATE_FILE" # : because > alone can fail if noclobber is set

echo "Cleaning up existing split tunnel pids..."

mullvad split-tunnel clear >> ./out.log

echo "Split tunnel running, ${#EXCLUDED_APPS[*]} apps excluded."

while true; do
  for app in "${EXCLUDED_APPS[@]}"; do
    # echo "Checking for app: $app"

    pgrep -f "$app" | while read -r pid; do
      if ! grep -q "^$pid$" "$STATE_FILE"; then
        echo -e "$app [$pid]" >> ./out.log
        if mullvad split-tunnel add "$pid" >> ./out.log; then
          echo "$pid" >> "$STATE_FILE"
        else 
          echo "Failed to add $app [$pid] to split tunnel"
        fi
      fi
    done
  done
  
  sleep 5
done

