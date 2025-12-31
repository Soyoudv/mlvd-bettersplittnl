#!/usr/bin/env bash

# ---------------------------------- FUNCTIONS ---------------------------------- #

cleanup(){
  echo -e "\e[96mCleaning up split tunnel pids...\e[0m"
  mullvad split-tunnel clear > /dev/null 2>&1
}

cleanup_exit(){
  echo ""
  cleanup
}

# ---------------------------------- LOAD CONFIG ---------------------------------- #
#load excluded apps from config
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mst"
EXCLUDED_APPS_FILE="$CONFIG_DIR/excluded-apps.txt"
if [ ! -f "$EXCLUDED_APPS_FILE" ]; then
  echo "Missing excluded apps file: $EXCLUDED_APPS_FILE" >&2
  exit 1
fi

# ---------------------------------- ARGUMENTS ---------------------------------- #
while getopts ":esc" opt; do
  case ${opt} in
    e)
      echo -e "\e[91mOuverture du fichier de configuration pour modification...\e[0m"
      xdg-open "$EXCLUDED_APPS_FILE"
      exit 1
    ;;
    s)
      echo -e "\e[91mExécution en mode silencieux...\e[0m"
      exec >/dev/null 2>&1
    ;;
    c)
      echo -e "\e[91mNettoyage des processus en cours d'exécution...\e[0m"
      mullvad split-tunnel clear > /dev/null 2>&1
      exit 1
    ;;
    ?)
      echo -e "\e[91mInvalid option: -${OPTARG}.\e[0m"
      exit 1
    ;;
  esac
done
# ---------------------------------- MAIN SCRIPT ---------------------------------- #
trap cleanup_exit EXIT

echo -e "\e[96mUsing excluded apps list from:\e[0m \e[95m$EXCLUDED_APPS_FILE\e[0m"

#read excluded apps into array
mapfile -t EXCLUDED_APPS < "$EXCLUDED_APPS_FILE"

#check if any excluded apps were found, else open config for editing
if [ ${#EXCLUDED_APPS[@]} -eq 0 ]; then
  echo -e "\e[91mNo excluded apps found in $EXCLUDED_APPS_FILE\e[0m" >&2
  xdg-open "$EXCLUDED_APPS_FILE"
  exit 1
fi

cleanup

# state file to keep track of added pids
STATE_FILE="$HOME/.cache/mullvad-split-pids"
mkdir -p "$(dirname "$STATE_FILE")" #ensure state file directory exists
: > "$STATE_FILE" # reset state file // : because > alone can fail if noclobber is set


echo -e "\e[1mSplit tunnel running, ${#EXCLUDED_APPS[*]} apps excluded.\e[0m"

while true; do
  for app in "${EXCLUDED_APPS[@]}"; do
    # echo "Checking for app: $app"

    pgrep -f "$app" | while read -r pid; do
      if ! grep -q "^$pid$" "$STATE_FILE"; then
        echo -e "\e[95m$app\e[0m [\e[96m$pid\e[0m] \e[90mexcluded\e[0m"
        if mullvad split-tunnel add "$pid" > /dev/null 2>&1; then
          echo "$pid" >> "$STATE_FILE"
        else 
          echo "Failed to add $app [$pid] to split tunnel"
        fi
      fi
    done
  done
  
  sleep 5
done

