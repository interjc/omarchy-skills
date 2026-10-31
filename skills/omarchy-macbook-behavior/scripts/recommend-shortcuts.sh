#!/usr/bin/env bash
set -euo pipefail

(($# == 0)) || { printf 'Usage: recommend-shortcuts.sh (read-only; no arguments)\n' >&2; exit 1; }

printf '%s\n' 'Effective Hyprland bindings (live session, JSON):'
if command -v hyprctl >/dev/null 2>&1 && binds=$(hyprctl binds -j 2>/dev/null); then
  printf '%s\n' "$binds"
else
  printf '%s\n' 'Unavailable: run this auditor inside your Hyprland session.'
fi

printf '\n%s\n' \
  'Upstream snapshot, NOT an assertion about your effective bindings:' \
  'Omarchy quattro bda3aaf6955404712dbd46541e6c8a75a2b16b7c (2026-10-31).' \
  'Latest stable tag checked separately: v4.0.6; the Lua workflow targets quattro.'
printf '\n%-24s %s\n' 'Action' 'Snapshot binding'
printf '%-24s %s\n' \
  'Screenshot' 'Print / Super+Ctrl+Alt+C -> omarchy-capture-screenshot' \
  'Clipboard history' 'Super+Ctrl+V' \
  'Copy / paste' 'Super+C / Super+V' \
  'Omarchy menu' 'Super+Space' \
  'Input language' 'Super+I / Super+Shift+I (native next / previous)' \
  'Terminal prefix' 'Ctrl+Space (non-consuming direct-input helper)' \
  'Calculator' 'Super+Shift+Q (if preinstalled-app bindings enabled)' \
  'Close window' 'Super+W / Super+Q' \
  'Audio panel' 'Super+Ctrl+A'

printf '\n%s\n' \
  'Optional choices, not universal recommendations:' \
  '  Super+Ctrl+A screenshot replaces Audio; use the menu for Audio afterward.' \
  '  Alt+Shift+4 is another screenshot chord, not literal macOS Cmd+Shift+4.' \
  '  Super+Shift+Z adds clipboard history, replacing any existing use of that chord.' \
  'Check the live bindings above before choosing. F12 is not a snapshot screenshot default.' \
  'Keep Super+Space for the menu and Ctrl+Space for terminal prefixes by default.' \
  'This auditor never edits files or prompts to apply. Use setup.sh for confirmed choices.'

printf '\n%s\n' 'Personal source excerpts (not the full effective configuration):'
for file in "$HOME/.config/hypr/bindings.lua" "$HOME/.config/hypr/macbook_behavior.lua"; do
  if [[ -f $file ]]; then
    printf '\n%s\n' "$file"
    grep -nE 'o[.]bind|hl[.]unbind|no_screen_share|omasnap|omarchy-capture-screenshot' "$file" || true
  fi
done
