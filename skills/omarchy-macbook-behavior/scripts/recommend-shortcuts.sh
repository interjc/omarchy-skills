#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Omarchy Shortcut Auditor & Ergonomic Recommendation Engine
# ==============================================================================

BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

BINDINGS_LUA="$HOME/.config/hypr/bindings.lua"
FCITX5_CONFIG="$HOME/.config/fcitx5/config"

print_header() {
  echo -e "${BOLD}${CYAN}=================================================================${RESET}"
  echo -e "${BOLD}${CYAN}    Omarchy Built-in Shortcuts & Ergonomic Recommendations ⌨️     ${RESET}"
  echo -e "${BOLD}${CYAN}=================================================================${RESET}"
}

list_shortcuts() {
  echo -e "\n${BOLD}${BLUE}📋 Commonly Used Built-in Shortcuts vs Ergonomic Recommendations:${RESET}\n"
  printf "${BOLD}%-24s %-26s %-26s %-20s${RESET}\n" "Category" "Omarchy Default" "Ergonomic Recommendation" "Muscle Memory"
  echo "------------------------------------------------------------------------------------------------------"
  printf "%-24s %-26s %-26s %-20s\n" "Clipboard History" "SUPER + CTRL + V" "SUPER + SHIFT + Z" "Alfred (Cmd+Shift+Z)"
  printf "%-24s %-26s %-26s %-20s\n" "Area Screenshot" "PRINT / F12 / None" "SUPER + CTRL + A" "Snipaste / WeChat"
  printf "%-24s %-26s %-26s %-20s\n" "Area Screenshot (Mac)" "PRINT / F12" "ALT + SHIFT + 4" "macOS (Cmd+Shift+4)"
  printf "%-24s %-26s %-26s %-20s\n" "Universal Copy" "SUPER + C" "SUPER + C (Keep)" "macOS (Cmd+C)"
  printf "%-24s %-26s %-26s %-20s\n" "Universal Paste" "SUPER + V" "SUPER + V (Keep)" "macOS (Cmd+V)"
  printf "%-24s %-26s %-26s %-20s\n" "App Launcher / Search" "SUPER + SPACE" "SUPER + SPACE (Keep)" "Spotlight / Raycast"
  printf "%-24s %-26s %-26s %-20s\n" "Launcher / IME Swap" "SUPER+SPACE / CTRL+SPACE" "Super+Space (IME) / Ctrl+Space (Menu)" "macOS Modern Input"
  printf "%-24s %-26s %-26s %-20s\n" "System Menu (Power)" "SUPER + ESCAPE" "SUPER + ESCAPE (Keep)" "macOS Apple Menu"
  printf "%-24s %-26s %-26s %-20s\n" "Close Active Window" "SUPER + W" "SUPER + W (Keep)" "macOS (Cmd+W)"
  printf "%-24s %-26s %-26s %-20s\n" "Quick Calculator" "SUPER + CTRL + Q" "SUPER + CTRL + Q (Keep)" "macOS Spotlight Calc"
  printf "%-24s %-26s %-26s %-20s\n" "Emoji Picker" "SUPER + CTRL + E" "SUPER + CTRL + E (Keep)" "macOS (Cmd+Ctrl+Space)"
  echo "------------------------------------------------------------------------------------------------------"
  echo -e "${YELLOW}* Note: 'SUPER + CTRL + A' is mapped by default to Audio. Rebinding to Screenshot will unbind Audio.${RESET}\n"
}

check_current_status() {
  echo -e "${BOLD}${BLUE}🔍 Current Custom Keybindings in ~/.config/hypr/bindings.lua:${RESET}"
  if [ -f "$BINDINGS_LUA" ]; then
    grep -E "SUPER \+ CTRL \+ A|SUPER \+ SHIFT \+ Z|ALT \+ SHIFT \+ 4|omasnap|CTRL \+ SPACE|SUPER \+ SPACE" "$BINDINGS_LUA" || echo "  (No custom overrides found yet)"
  else
    echo "  (bindings.lua not yet created)"
  fi
  echo ""
}

apply_recommendations() {
  local apply_screenshot="$1"
  local apply_clipboard="$2"
  local apply_space_swap="${3:-false}"

  mkdir -p "$(dirname "$BINDINGS_LUA")"
  touch "$BINDINGS_LUA"

  local modified=false

  # Handle Screenshot
  if [ "$apply_screenshot" = "super-ctrl-a" ]; then
    if ! grep -q "SUPER + CTRL + A.*omasnap" "$BINDINGS_LUA" 2>/dev/null; then
      echo -e "${GREEN}==> Adding SUPER + CTRL + A for omasnap screenshot (unbinding Audio)...${RESET}"
      cat << 'EOF' >> "$BINDINGS_LUA"

-- Omasnap screenshot overlay (SUPER + CTRL + A)
hl.unbind("PRINT")
hl.unbind("F12")
hl.unbind("SUPER + CTRL + A")
o.bind("PRINT", "Screenshot", "omasnap")
o.bind("F12", "Screenshot", "omasnap")
o.bind("SUPER + CTRL + A", "Screenshot", "omasnap")

hl.layer_rule({
  match = { namespace = "^omasnap$" },
  no_anim = true,
  animation = "none",
  no_screen_share = true,
})
EOF
      modified=true
    else
      echo "  SUPER + CTRL + A is already configured for omasnap."
    fi
  elif [ "$apply_screenshot" = "alt-shift-4" ]; then
    if ! grep -q "ALT + SHIFT + 4.*omasnap" "$BINDINGS_LUA" 2>/dev/null; then
      echo -e "${GREEN}==> Adding ALT + SHIFT + 4 for omasnap screenshot (macOS style)...${RESET}"
      cat << 'EOF' >> "$BINDINGS_LUA"

-- Omasnap screenshot overlay (macOS Cmd+Shift+4 style)
hl.unbind("PRINT")
hl.unbind("F12")
hl.unbind("ALT + SHIFT + 4")
o.bind("PRINT", "Screenshot", "omasnap")
o.bind("F12", "Screenshot", "omasnap")
o.bind("ALT + SHIFT + 4", "Area Screenshot (macOS Cmd+Shift+4)", "omasnap")

hl.layer_rule({
  match = { namespace = "^omasnap$" },
  no_anim = true,
  animation = "none",
  no_screen_share = true,
})
EOF
      modified=true
    else
      echo "  ALT + SHIFT + 4 is already configured for omasnap."
    fi
  fi

  # Handle Clipboard History
  if [ "$apply_clipboard" = "true" ]; then
    if ! grep -q "SUPER + SHIFT + Z" "$BINDINGS_LUA" 2>/dev/null; then
      echo -e "${GREEN}==> Adding SUPER + SHIFT + Z for Alfred-style clipboard history...${RESET}"
      cat << 'EOF' >> "$BINDINGS_LUA"

-- Clipboard history (Alfred style Super + Shift + Z)
hl.unbind("SUPER + SHIFT + Z")
o.bind("SUPER + SHIFT + Z", "Clipboard history", "omarchy-shell shell toggle omarchy.clipboard")
EOF
      modified=true
    else
      echo "  SUPER + SHIFT + Z is already configured for clipboard history."
    fi
  fi

  # Handle Super+Space / Ctrl+Space Swap
  if [ "$apply_space_swap" = "true" ]; then
    if ! grep -q "CTRL + SPACE" "$BINDINGS_LUA" 2>/dev/null; then
      echo -e "${GREEN}==> Swapping Super+Space (IME) and Ctrl+Space (Omarchy Menu)...${RESET}"
      cat << 'EOF' >> "$BINDINGS_LUA"

-- Menu / IME swap: release Super+Space to Fcitx5, bind Ctrl+Space to Omarchy menu
hl.unbind("SUPER + SPACE")
o.bind("CTRL + SPACE", "Omarchy menu", "omarchy-menu toggle")
EOF
      modified=true
    fi

    # Update Fcitx5 TriggerKeys
    if [ -f "$FCITX5_CONFIG" ]; then
      sed -i 's/^0=Control+space/0=Super+space/' "$FCITX5_CONFIG"
      fcitx5 -r -d >/dev/null 2>&1 || true
      echo -e "${GREEN}✔ Fcitx5 input method hotkey updated to Super+space!${RESET}"
    fi
  fi

  if [ "$modified" = true ]; then
    if command -v hyprctl >/dev/null 2>&1; then
      hyprctl reload 2>/dev/null || true
      echo -e "${GREEN}✔ Hyprland configuration reloaded successfully!${RESET}"
    fi
  fi
}

main() {
  print_header
  list_shortcuts
  check_current_status

  # Check if interactive
  if [ -t 0 ]; then
    echo -e "${BOLD}${YELLOW}Would you like to configure recommended shortcuts now?${RESET}"
    echo "  1) Area Screenshot: Super + Ctrl + A (Snipaste/WeChat style, unbinds Audio)"
    echo "  2) Area Screenshot: Alt + Shift + 4 (macOS style)"
    echo "  3) Keep current screenshot binding"
    read -r -p "Select screenshot option [1/2/3] (default: 1): " shot_choice </dev/tty || shot_choice="3"

    case "$shot_choice" in
      1) SHOT_OPTION="super-ctrl-a" ;;
      2) SHOT_OPTION="alt-shift-4" ;;
      *) SHOT_OPTION="none" ;;
    esac

    echo ""
    echo "  1) Clipboard History: Super + Shift + Z (Alfred style) [Recommended]"
    echo "  2) Keep current clipboard binding (Super + Ctrl + V)"
    read -r -p "Select clipboard option [1/2] (default: 1): " clip_choice </dev/tty || clip_choice="2"

    case "$clip_choice" in
      1) CLIP_OPTION="true" ;;
      *) CLIP_OPTION="false" ;;
    esac

    echo ""
    echo "  1) Swap Super+Space (IME) and Ctrl+Space (Launcher)"
    echo "  2) Keep default (Super+Space for Launcher, Ctrl+Space for IME)"
    read -r -p "Select Space key swap option [1/2] (default: 2): " space_choice </dev/tty || space_choice="2"

    case "$space_choice" in
      1) SPACE_OPTION="true" ;;
      *) SPACE_OPTION="false" ;;
    esac

    echo -e "\n${BOLD}Confirm the following changes to apply to ~/.config/hypr/bindings.lua:${RESET}"
    echo "  - Screenshot:  $SHOT_OPTION"
    echo "  - Clipboard:   $CLIP_OPTION (Super+Shift+Z)"
    echo "  - Space Swap:  $SPACE_OPTION"
    read -r -p "Proceed with modification? [y/N]: " confirm </dev/tty || confirm="n"

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      apply_recommendations "$SHOT_OPTION" "$CLIP_OPTION" "$SPACE_OPTION"
    else
      echo "No changes applied."
    fi
  fi
}

main "$@"
