#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf '%s\n' \
    'Usage: setup.sh [--natural-scroll | --traditional-scroll | --keep-trackpad]' \
    '                --screenshot-hotkey keep|super-ctrl-a|alt-shift-4|both' \
    '                --clipboard-hotkey keep|super-shift-z' \
    'Missing preferences are prompted on a TTY, or rejected without any writes.' \
    'Selecting a scroll direction enables three-finger drag, disable-while-typing,' \
    'and replacement four-finger gestures. No packages, IME, power or udev changes.' \
    "keep removes this installer's previous overrides, not your personal settings."
}

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

scroll=''
screenshot=''
clipboard=''
while (($#)); do
  case "$1" in
    --natural-scroll) scroll=true; shift ;;
    --traditional-scroll) scroll=false; shift ;;
    --keep-trackpad) scroll=keep; shift ;;
    --screenshot-hotkey|--clipboard-hotkey)
      (($# >= 2)) && [[ $2 != --* ]] || die "Missing value for $1"
      if [[ $1 == --screenshot-hotkey ]]; then screenshot=$2; else clipboard=$2; fi
      shift 2
      ;;
    --help|-h) usage; exit 0 ;;
    *) die "Unknown argument: $1 (see --help)" ;;
  esac
done

case "$screenshot" in ''|keep|super-ctrl-a|alt-shift-4|both) ;; *) die 'Invalid screenshot hotkey' ;; esac
case "$clipboard" in ''|keep|super-shift-z) ;; *) die 'Invalid clipboard hotkey' ;; esac

if [[ -z $scroll || -z $screenshot || -z $clipboard ]]; then
  [[ -t 0 && -t 1 ]] || die 'Noninteractive setup requires explicit trackpad, screenshot and clipboard preferences; see --help.'
  if [[ -z $scroll ]]; then
    printf '%s\n' 'Trackpad: natural / traditional / keep' \
      'natural or traditional enables three-finger drag and palm rejection while typing.' \
      'It replaces ALL upstream gestures: four fingers switch workspaces horizontally,' \
      'up/down toggle scratchpad, pinch-in opens the menu; three fingers are for drag.'
    read -r -p 'Trackpad choice (no default): ' choice || die 'No trackpad choice'
    case "$choice" in natural) scroll=true ;; traditional) scroll=false ;; keep) scroll=keep ;; *) die 'Invalid trackpad choice' ;; esac
  fi
  if [[ -z $screenshot ]]; then
    printf '%s\n' 'Screenshot: keep / super-ctrl-a (replaces Audio) / alt-shift-4 / both' \
      'Alt+Shift+4 is an alternative, not the same physical chord as macOS Cmd+Shift+4.'
    read -r -p 'Screenshot choice (no default): ' screenshot || die 'No screenshot choice'
    case "$screenshot" in keep|super-ctrl-a|alt-shift-4|both) ;; *) die 'Invalid screenshot choice' ;; esac
  fi
  if [[ -z $clipboard ]]; then
    printf '%s\n' 'Clipboard: keep / super-shift-z (adds an alias, replacing any binding on that chord)'
    read -r -p 'Clipboard choice (no default): ' clipboard || die 'No clipboard choice'
    case "$clipboard" in keep|super-shift-z) ;; *) die 'Invalid clipboard choice' ;; esac
  fi
  printf 'Apply trackpad=%s, screenshot=%s, clipboard=%s?\n' "$scroll" "$screenshot" "$clipboard"
  read -r -p 'Proceed [y/N]: ' confirm || die 'No confirmation'
  [[ $confirm == y || $confirm == Y ]] || { printf 'No changes applied.\n'; exit 0; }
fi

script_dir=$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")
references="$script_dir/../references"
hypr="$HOME/.config/hypr"
main="$hypr/hyprland.lua"
override="$hypr/macbook_behavior.lua"
header='-- Managed by omarchy-macbook-behavior setup.sh; edit preferences by rerunning setup.'
[[ -f $main && ! -L $main ]] || die 'Expected a regular ~/.config/hypr/hyprland.lua; symlinks and older .conf setups require manual integration.'
[[ ! -L $override ]] || die 'Refusing to replace a symlinked managed override.'
if [[ -e $override ]]; then
  [[ -f $override ]] || die 'Managed override is not a regular file.'
  IFS= read -r first_line < "$override" || true
  [[ ${first_line:-} == "$header" ]] || die 'macbook_behavior.lua already exists and is not owned by this installer.'
fi

# Old releases wrote these directly into personal files. Do not silently delete them.
if [[ $scroll != keep && -f $hypr/input.lua ]] && grep -q 'hl[.]gesture' "$hypr/input.lua"; then
  die 'Personal input.lua contains gestures. Review/migrate them manually before enabling replacement gestures (see SKILL.md).'
fi
if [[ -f $hypr/bindings.lua ]] && grep -q 'omasnap' "$hypr/bindings.lua" && grep -q 'no_screen_share' "$hypr/bindings.lua"; then
  die 'Review legacy omasnap rules in bindings.lua: remove its no_screen_share rule before setup (see SKILL.md).'
fi

screenshot_command=''
if [[ $screenshot != keep ]]; then
  capture_source=$(type -P omarchy-capture-screenshot || true)
  # Recognize a command invocation, not a comment, argument or variable name.
  if [[ -r $capture_source ]] && grep -qE '^[[:space:]]*(exec[[:space:]]+)?omasnap([[:space:]]|$)' "$capture_source"; then
    screenshot_command=omarchy-capture-screenshot
  else
    screenshot_command=omasnap
  fi
  type -P omasnap >/dev/null || die 'Screenshot shortcuts require an installed omasnap executable on PATH; no files changed.'
  printf 'Screenshot command: %s\n' "$screenshot_command"
fi

temp=$(mktemp -d "$hypr/.macbook-behavior.XXXXXX")
trap 'rm -rf -- "$temp"' EXIT

# Only our marked blocks are replaced. Unrecognized layouts fail before installation.
awk -v trackpad="$scroll" '
  /^-- BEGIN omarchy-macbook-behavior (gestures|overrides)$/ {
    if (block) exit 1
    block = $4
    next
  }
  /^-- END omarchy-macbook-behavior (gestures|overrides)$/ {
    if (!block || block != $4) exit 1
    block = ""
    next
  }
  block { next }
  /^[[:space:]]*require\("default[.]hypr[.]omarchy"\)[[:space:]]*$/ {
    defaults++
    if (trackpad != "keep") {
      print "-- BEGIN omarchy-macbook-behavior gestures"
      print "omarchy_default_gestures = false"
      print "-- END omarchy-macbook-behavior gestures"
    }
  }
  { print }
  END {
    if (block || defaults != 1) exit 1
    print "-- BEGIN omarchy-macbook-behavior overrides"
    print "require(\"hypr.macbook_behavior\")"
    print "-- END omarchy-macbook-behavior overrides"
  }
' "$main" > "$temp/hyprland.lua" || die 'Unsupported defaults import or malformed managed markers; integrate manually.'

printf '%s\n' "$header" > "$temp/macbook_behavior.lua"
if [[ $scroll != keep ]]; then
  sed "s/natural_scroll = false/natural_scroll = $scroll/" "$references/hyprland-input.lua" >> "$temp/macbook_behavior.lua"
fi
if [[ $screenshot == super-ctrl-a || $screenshot == both ]]; then
  printf '%s\n' 'hl.unbind("SUPER + CTRL + A")' >> "$temp/macbook_behavior.lua"
  printf 'o.bind("SUPER + CTRL + A", "Screenshot", "%s")\n' "$screenshot_command" >> "$temp/macbook_behavior.lua"
fi
if [[ $screenshot == alt-shift-4 || $screenshot == both ]]; then
  printf '%s\n' 'hl.unbind("ALT + SHIFT + 4")' >> "$temp/macbook_behavior.lua"
  printf 'o.bind("ALT + SHIFT + 4", "Screenshot", "%s")\n' "$screenshot_command" >> "$temp/macbook_behavior.lua"
fi
if [[ $clipboard == super-shift-z ]]; then
  printf '%s\n' 'hl.unbind("SUPER + SHIFT + Z")' \
    'o.bind("SUPER + SHIFT + Z", "Clipboard history", "omarchy-shell shell toggle omarchy.clipboard")' >> "$temp/macbook_behavior.lua"
fi

for file in macbook_behavior.lua hyprland.lua; do
  target="$hypr/$file"
  if [[ -f $target ]] && cmp -s "$target" "$temp/$file"; then
    continue
  fi
  if [[ -f $target ]]; then
    backup=$(mktemp "$target.macbook-backup.XXXXXX")
    cp -p -- "$target" "$backup"
    chmod --reference="$target" "$temp/$file"
    printf 'Backup: %s\n' "$backup"
  fi
  mv -- "$temp/$file" "$target"
  printf 'Updated: %s\n' "$target"
done
printf '%s\n' 'Setup complete. Personal input.lua, bindings.lua and IME/power settings were not rewritten.' \
  'No reload was requested by this script; Hyprland may auto-reload when files change.' \
  'In your desktop session run: hyprctl reload && hyprctl configerrors' \
  'Then test drag, gestures, shortcuts and scrolling screenshots. See SKILL.md for rollback.'
