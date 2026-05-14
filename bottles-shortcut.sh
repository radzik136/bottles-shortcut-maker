#!/bin/bash

############################################################
#  SETTINGS
############################################################

REAL_HOME="$(getent passwd "$USER" | cut -d: -f6)"
BOTTLES_DIR="$REAL_HOME/.var/app/com.usebottles.bottles/data/bottles/bottles"
APPDIR="$(dirname "$(readlink -f "$0")")"
export PATH="$APPDIR/usr/bin:$PATH"

ICON_FALLBACK="com.usebottles.bottles"
SHORTCUT_LOCATION=""

############################################################
#  HELPERS
############################################################

error() {
  zenity --error --title="Error" --width=400 --text="$1"
  exit 1
}

is_back() { [ "$1" = "Back" ]; }

choose_shortcut_location() {
  zenity --list \
    --title="Choose shortcut location" \
    --column="Location" \
    "Desktop" \
    "Applications menu" \
    --height=200 --width=350 \
    --extra-button="Back"
}

choose_icon_with_default_dir() {
  local default_dir="$1"

  if [ -d "$default_dir" ]; then
    zenity --file-selection \
      --title="Wybierz ikonę (PNG/ICO)" \
      --filename="$default_dir/" \
      --file-filter="Ikony | *.png *.ico" \
      --file-filter="Wszystkie pliki | *" \
      --extra-button="Pomiń" \
      --width=600 --height=400
  else
    zenity --file-selection \
      --title="Wybierz ikonę (PNG/ICO)" \
      --file-filter="Ikony | *.png *.ico" \
      --file-filter="Wszystkie pliki | *" \
      --extra-button="Pomiń" \
      --width=600 --height=400
  fi
}

############################################################
#  BOTTLE SELECTION
############################################################

choose_bottle() {
  [ ! -d "$BOTTLES_DIR" ] && error "Bottles (Flatpak) not found."

  ls "$BOTTLES_DIR" | zenity --list \
    --title="Select a bottle" \
    --column="Bottle" \
    --height=600 --width=500 \
    --extra-button="Back"
}

############################################################
#  PROGRAM LIST (bottle.yml + yq)
############################################################

scan_bottle_programs() {
  local bottle="$1"
  local yml="$BOTTLES_DIR/$bottle/bottle.yml"

  [ ! -f "$yml" ] && error "bottle.yml not found for bottle: $bottle"

  yq '.External_Programs[] | select(.removed != true) | .name' "$yml" \
    | sed 's/^"//; s/"$//' \
    | sort
}

choose_program_in_bottle() {
  local bottle="$1"

  local programs
  programs=$(scan_bottle_programs "$bottle") || return 1

  if [ -z "$programs" ]; then
    error "No registered programs found in this bottle."
  fi

  local selected
  selected=$(echo "$programs" | zenity --list \
    --title="Select a program" \
    --column="Program" \
    --width=600 --height=500 \
    --extra-button="Back")

  if [ $? -ne 0 ] || [ -z "$selected" ]; then
    echo "Back"
    return
  fi

  echo "$selected"
}

############################################################
#  SHORTCUT CREATION (run -p)
############################################################

create_shortcut_from_program() {
  local bottle="$1"
  local program="$2"
  local yml="$BOTTLES_DIR/$bottle/bottle.yml"

  ##########################################################
  # 1. Pobierz ścieżkę .exe i katalog
  ##########################################################

  exe_path=$(yq ".External_Programs[] | select(.name == \"$program\") | .path" "$yml" | sed 's/^\"//; s/\"$//')
  exe_dir=$(dirname "$exe_path")

  ##########################################################
  # 2. ZAWSZE pytamy o ikonę, domyślnie w katalogu .exe
  ##########################################################

  user_icon=$(choose_icon_with_default_dir "$exe_dir")
  rc=$?

  # Ikona z bottle.yml
  bottle_icon=$(yq ".External_Programs[] | select(.name == \"$program\") | .icon" "$yml" | sed 's/^\"//; s/\"$//')
  [ "$bottle_icon" = "null" ] && bottle_icon=""

  # Logika wyboru ikony
  if [ $rc -ne 0 ] || [ "$user_icon" = "Pomiń" ] || [ -z "$user_icon" ]; then
    if [ -n "$bottle_icon" ]; then
      icon="$bottle_icon"
    else
      icon="$ICON_FALLBACK"
    fi
  else
    icon="$user_icon"
  fi

  ##########################################################
  # 3. Wybór lokalizacji skrótu
  ##########################################################

  SHORTCUT_LOCATION=$(choose_shortcut_location)
  if [ -z "$SHORTCUT_LOCATION" ] || [ "$SHORTCUT_LOCATION" = "Back" ]; then
    return
  fi

  if [ "$SHORTCUT_LOCATION" = "Desktop" ]; then
    TARGET_DIR="$(xdg-user-dir DESKTOP)"
  else
    TARGET_DIR="$HOME/.local/share/applications"
  fi

  mkdir -p "$TARGET_DIR"

  ##########################################################
  # 4. Tworzenie skrótu
  ##########################################################

  local SAFE_NAME
  SAFE_NAME=$(echo "$program" | tr ' ' '_' | tr -cd '[:alnum:]_')
  local DESKTOP_FILE="$TARGET_DIR/${SAFE_NAME}.desktop"

  printf '%s\n' \
"[Desktop Entry]" \
"Name=$program" \
"Exec=flatpak run --command=bottles-cli com.usebottles.bottles run -p \"$program\" -b \"$bottle\" -- %u" \
"Type=Application" \
"Icon=$icon" \
"Categories=Game;Wine;" \
"Terminal=false" \
"StartupWMClass=$program" \
> "$DESKTOP_FILE"

  chmod +x "$DESKTOP_FILE"

  zenity --info \
    --title="Gotowe" \
    --width=400 \
    --text="Skrót został utworzony:\n\n$DESKTOP_FILE"
}

############################################################
#  FEATURE OVERVIEW
############################################################

feature_overview() {
  zenity --info \
    --title="Feature overview" \
    --width=550 \
    --height=420 \
    --text="Overview of available features:\n
• Always allows manual icon selection
• Icon dialog opens in the .exe directory
• Uses bottle.yml icon only if user skips selection
• Clean Back/Exit navigation"
}

############################################################
#  MAIN MENU
############################################################

while true; do
  MODE=$(zenity --list \
    --title="Choose mode" \
    --column="Option" \
    "Create shortcut from bottle program (recommended)" \
    "Feature overview" \
    --height=300 --width=400 \
    --extra-button="Back")

  is_back "$MODE" && continue
  [ -z "$MODE" ] && exit 0

  case "$MODE" in
    "Create shortcut from bottle program (recommended)")
      bottle=$(choose_bottle)
      is_back "$bottle" && continue
      program=$(choose_program_in_bottle "$bottle")
      is_back "$program" && continue
      create_shortcut_from_program "$bottle" "$program"
      ;;
    "Feature overview")
      feature_overview
      ;;
  esac
done
