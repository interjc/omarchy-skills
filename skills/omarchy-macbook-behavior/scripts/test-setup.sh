#!/usr/bin/env bash
set -euo pipefail

scripts=$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")
root=$(mktemp -d "${TMPDIR:-/tmp}/macbook-behavior-test.XXXXXX")
trap 'rm -rf -- "$root"' EXIT
export HOME="$root/home"
mkdir -p "$HOME/.config/hypr" "$HOME/.config/fcitx5" "$HOME/.local/share/fcitx5/rime" "$root/bin" "$root/omarchy/bin"
export MOCK_LOG="$root/unexpected-commands"
export OMARCHY_PATH="$root/omarchy"
# Whitelist utilities so host screenshot tools and Omarchy sources cannot leak in.
for command in bash dirname realpath mkdir ln chmod cp rm tar sha256sum grep awk sed mktemp cmp mv cat lua script; do
  if executable=$(type -P "$command"); then
    ln -s "$executable" "$root/bin/$command"
  fi
done
export PATH="$root/bin"
hash -r

cat > "$root/bin/forbidden" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$0 $*" >> "$MOCK_LOG"
exit 99
MOCK
chmod +x "$root/bin/forbidden"
for command in sudo pacman fcitx5 fcitx5-remote git systemctl udevadm omarchy-pkg-add omarchy-setup-input; do
  ln -s forbidden "$root/bin/$command"
done
ln -s "$OMARCHY_PATH/bin/omarchy-capture-screenshot" "$root/bin/omarchy-capture-screenshot"
cat > "$root/bin/hyprctl" <<'MOCK'
#!/usr/bin/env bash
if [[ $* == 'binds -j' && ${MOCK_HYPR_FAIL:-0} == 0 ]]; then
  printf '%s\n' '[{"key":"CUSTOM_LIVE_BIND","description":"Personal binding"}]'
else
  exit 1
fi
MOCK
chmod +x "$root/bin/hyprctl"

hypr="$HOME/.config/hypr"
cat > "$hypr/hyprland.lua" <<'LUA'
-- Personal preamble remains intact.
require("default.hypr.omarchy")
require("hypr.input")
require("hypr.bindings")
personal_loaded = true
LUA
printf '%s\n' '-- Personal keyboard settings, not generated.' 'personal_keyboard = "de"' > "$hypr/input.lua"
printf '%s\n' '-- Personal bindings remain intact.' > "$hypr/bindings.lua"
printf '%s\n' 'custom profile' > "$HOME/.config/fcitx5/profile"
printf '%s\n' 'custom hotkeys' > "$HOME/.config/fcitx5/config"
printf '%s\n' 'custom dictionaries' > "$HOME/.local/share/fcitx5/rime/default.custom.yaml"
cp -a "$HOME" "$root/original"

snapshot() { tar --sort=name --mtime=@0 -C "$HOME" -cf - . | sha256sum; }
unchanged_failure() {
  local before
  before=$(snapshot)
  if bash "$scripts/setup.sh" "$@" </dev/null > "$root/output" 2>&1; then
    printf 'Expected failure: %s\n' "$*" >&2
    exit 1
  fi
  [[ $(snapshot) == "$before" ]] || { printf 'Failure changed HOME: %s\n' "$*" >&2; exit 1; }
}

unchanged_failure
unchanged_failure --natural-scroll
unchanged_failure --natural-scroll --screenshot-hotkey keep
unchanged_failure --screenshot-hotkey
unchanged_failure --clipboard-hotkey
unchanged_failure --screenshot-hotkey --natural-scroll
unchanged_failure --natural-scroll --screenshot-hotkey invalid --clipboard-hotkey keep
unchanged_failure --natural-scroll --screenshot-hotkey keep --clipboard-hotkey invalid
unchanged_failure --unknown
unchanged_failure --natural-scroll --screenshot-hotkey keep --clipboard-hotkey keep --unknown

# An unsupported Lua entrypoint must fail without leaving even a temporary file.
cp "$hypr/hyprland.lua" "$root/main"
printf '%s\n' '-- Older/unrecognized layout.' > "$hypr/hyprland.lua"
unchanged_failure --natural-scroll --screenshot-hotkey keep --clipboard-hotkey keep
cp "$root/main" "$hypr/hyprland.lua"
printf '%s\n' '-- BEGIN omarchy-macbook-behavior gestures' >> "$hypr/hyprland.lua"
unchanged_failure --natural-scroll --screenshot-hotkey keep --clipboard-hotkey keep
cp "$root/main" "$hypr/hyprland.lua"
rm "$hypr/hyprland.lua"
ln -s "$root/main" "$hypr/hyprland.lua"
unchanged_failure --natural-scroll --screenshot-hotkey keep --clipboard-hotkey keep
rm "$hypr/hyprland.lua"
cp "$root/main" "$hypr/hyprland.lua"
printf '%s\n' '-- Personal file with a colliding name.' > "$hypr/macbook_behavior.lua"
unchanged_failure --natural-scroll --screenshot-hotkey keep --clipboard-hotkey keep
rm "$hypr/macbook_behavior.lua"
ln -s "$root/main" "$hypr/macbook_behavior.lua"
unchanged_failure --natural-scroll --screenshot-hotkey keep --clipboard-hotkey keep
rm "$hypr/macbook_behavior.lua"
printf '%s\n' 'hl.gesture({ fingers = 3, direction = "up", action = "special" })' >> "$hypr/input.lua"
unchanged_failure --natural-scroll --screenshot-hotkey keep --clipboard-hotkey keep
cp "$root/original/.config/hypr/input.lua" "$hypr/input.lua"
printf '%s\n' '-- omasnap legacy rule' '-- no_screen_share = true' >> "$hypr/bindings.lua"
unchanged_failure --natural-scroll --screenshot-hotkey keep --clipboard-hotkey keep
cp "$root/original/.config/hypr/bindings.lua" "$hypr/bindings.lua"

# Neither an unknown source nor a legacy wrapper is an omasnap substitute.
cp "$root/bin/forbidden" "$OMARCHY_PATH/bin/omarchy-capture-screenshot"
printf '%s\n' '# exec omasnap --notify' \
  'omasnap_args=(--notify)' 'printf "%s\\n" omasnap' >> "$OMARCHY_PATH/bin/omarchy-capture-screenshot"
cp "$OMARCHY_PATH/bin/omarchy-capture-screenshot" "$root/unknown-capture"
unchanged_failure --keep-trackpad --screenshot-hotkey super-ctrl-a --clipboard-hotkey super-shift-z
grep -q 'require an installed omasnap' "$root/output"
cp "$root/bin/forbidden" "$root/legacy-capture"
printf '%s\n' 'omarchy-capture-region smart' 'grim -g "$SELECTION" "$FILEPATH"' >> "$root/legacy-capture"
cp "$root/legacy-capture" "$OMARCHY_PATH/bin/omarchy-capture-screenshot"
unchanged_failure --keep-trackpad --screenshot-hotkey both --clipboard-hotkey keep
rm "$OMARCHY_PATH/bin/omarchy-capture-screenshot"
unchanged_failure --keep-trackpad --screenshot-hotkey alt-shift-4 --clipboard-hotkey keep
# Keeping screenshot settings requires no screenshot tool at all.
bash "$scripts/setup.sh" --keep-trackpad --screenshot-hotkey keep --clipboard-hotkey keep > "$root/output"

cp "$root/bin/forbidden" "$OMARCHY_PATH/bin/omarchy-capture-screenshot"
printf '%s\n' 'exec omasnap "${omasnap_args[@]}"' >> "$OMARCHY_PATH/bin/omarchy-capture-screenshot"
cp "$OMARCHY_PATH/bin/omarchy-capture-screenshot" "$root/native-capture"
unchanged_failure --keep-trackpad --screenshot-hotkey super-ctrl-a --clipboard-hotkey keep
ln -s forbidden "$root/bin/omasnap"
rm "$root/bin/omarchy-capture-screenshot"
bash "$scripts/setup.sh" --keep-trackpad --screenshot-hotkey super-ctrl-a --clipboard-hotkey keep > "$root/output"
grep -qx 'Screenshot command: omasnap' "$root/output"
ln -s "$OMARCHY_PATH/bin/omarchy-capture-screenshot" "$root/bin/omarchy-capture-screenshot"

for source in unknown missing bare-call; do
  case "$source" in
    unknown) cp "$root/unknown-capture" "$OMARCHY_PATH/bin/omarchy-capture-screenshot"; expected_command=omasnap ;;
    missing) rm "$OMARCHY_PATH/bin/omarchy-capture-screenshot"; expected_command=omasnap ;;
    bare-call)
      cp "$root/bin/forbidden" "$OMARCHY_PATH/bin/omarchy-capture-screenshot"
      printf '%s\n' '  omasnap "$@"' >> "$OMARCHY_PATH/bin/omarchy-capture-screenshot"
      expected_command=omarchy-capture-screenshot ;;
  esac
  bash "$scripts/setup.sh" --keep-trackpad --screenshot-hotkey super-ctrl-a --clipboard-hotkey super-shift-z > "$root/output"
  grep -qx "Screenshot command: $expected_command" "$root/output"
  grep -qF "\"Screenshot\", \"$expected_command\")" "$hypr/macbook_behavior.lua"
done

# Inspect what PATH will execute, even when OMARCHY_PATH points at another build.
rm "$root/bin/omarchy-capture-screenshot"
ln -s "$root/path-capture" "$root/bin/omarchy-capture-screenshot"
for backend in legacy native; do
  if [[ $backend == legacy ]]; then
    cp "$root/native-capture" "$OMARCHY_PATH/bin/omarchy-capture-screenshot"
    expected_command=omasnap
  else
    cp "$root/legacy-capture" "$OMARCHY_PATH/bin/omarchy-capture-screenshot"
    expected_command=omarchy-capture-screenshot
  fi
  cp "$root/$backend-capture" "$root/path-capture"
  bash "$scripts/setup.sh" --keep-trackpad --screenshot-hotkey super-ctrl-a --clipboard-hotkey super-shift-z > "$root/output"
  grep -qx "Screenshot command: $expected_command" "$root/output"
  grep -qF "\"Screenshot\", \"$expected_command\")" "$hypr/macbook_behavior.lua"
done
rm "$root/bin/omarchy-capture-screenshot"
ln -s "$OMARCHY_PATH/bin/omarchy-capture-screenshot" "$root/bin/omarchy-capture-screenshot"
cp "$root/native-capture" "$OMARCHY_PATH/bin/omarchy-capture-screenshot"

for backend in native legacy; do
  if [[ $backend == native ]]; then
    expected_command=omarchy-capture-screenshot
  else
    cp "$root/legacy-capture" "$OMARCHY_PATH/bin/omarchy-capture-screenshot"
    expected_command=omasnap
  fi
  for trackpad in --natural-scroll --traditional-scroll --keep-trackpad; do
    for screenshot in keep super-ctrl-a alt-shift-4 both; do
      for clipboard in keep super-shift-z; do
        bash "$scripts/setup.sh" "$trackpad" --screenshot-hotkey "$screenshot" --clipboard-hotkey "$clipboard" > "$root/output"
        if [[ $screenshot != keep ]]; then
          grep -qx "Screenshot command: $expected_command" "$root/output"
          grep -qF "\"Screenshot\", \"$expected_command\")" "$hypr/macbook_behavior.lua"
        elif grep -q '"Screenshot"' "$hypr/macbook_behavior.lua"; then
          printf 'Screenshot keep generated a binding\n' >&2; exit 1
        fi
        before=$(snapshot)
        bash "$scripts/setup.sh" "$trackpad" --screenshot-hotkey "$screenshot" --clipboard-hotkey "$clipboard" > "$root/output"
        [[ $(snapshot) == "$before" ]] || { printf 'Rerun is not idempotent\n' >&2; exit 1; }
        if grep -qE '^(Updated|Backup):' "$root/output"; then
          printf 'Identical rerun rewrote a file\n' >&2; exit 1
        fi
        if command -v lua >/dev/null 2>&1; then
          lua - "$hypr/hyprland.lua" "$trackpad" "$screenshot" "$clipboard" "$expected_command" <<'LUA'
local main, trackpad, screenshot, clipboard, expected_command = arg[1], arg[2], arg[3], arg[4], arg[5]
local count, configs, binds = 0, 0, {}
hl = {
  config = function(config)
    assert(personal_loaded, "override must run AFTER personal configuration")
    assert(config.input.touchpad.natural_scroll == (trackpad == "--natural-scroll"))
    assert(config.input.touchpad.drag_3fg == 1)
    configs = configs + 1
  end,
  gesture = function(gesture)
    assert(omarchy_default_gestures == false, "disable defaults before adding replacements")
    assert(gesture.fingers == 4, "three fingers are reserved for drag")
    count = count + 1
  end,
  unbind = function() end,
}
o = { bind = function(key, _, command)
  assert(not binds[key], "duplicate binding")
  assert(command == expected_command or command == "omarchy-shell shell toggle omarchy.clipboard")
  binds[key] = true
end }
function require(name)
  if name == "default.hypr.omarchy" then
    assert((omarchy_default_gestures == false) == (trackpad ~= "--keep-trackpad"), "flag must precede defaults import")
  elseif name == "hypr.macbook_behavior" then
    dofile(main:gsub("hyprland.lua$", "macbook_behavior.lua"))
  end
end
dofile(main)
assert(count == (trackpad == "--keep-trackpad" and 0 or 4))
assert(configs == (trackpad == "--keep-trackpad" and 0 or 1))
assert(not not binds["SUPER + CTRL + A"] == (screenshot == "both" or screenshot == "super-ctrl-a"))
assert(not not binds["ALT + SHIFT + 4"] == (screenshot == "both" or screenshot == "alt-shift-4"))
assert(not not binds["SUPER + SHIFT + Z"] == (clipboard == "super-shift-z"))
assert(not binds.PRINT and not binds.F12)
LUA
        fi
      done
    done
  done
done

# Match the live legacy release: no default/hypr/gestures.lua, personal input kept.
[[ ! -e $OMARCHY_PATH/default/hypr/gestures.lua ]]
bash "$scripts/setup.sh" --keep-trackpad --screenshot-hotkey super-ctrl-a --clipboard-hotkey super-shift-z > "$root/output"
grep -qx 'Screenshot command: omasnap' "$root/output"
if grep -q 'omarchy_default_gestures' "$hypr/hyprland.lua" ||
   grep -qE 'hl[.](config|gesture)|--notify|--save|--capture-fullscreen' "$hypr/macbook_behavior.lua"; then
  printf 'Shortcut-only setup added trackpad changes or screenshot arguments\n' >&2; exit 1
fi
cmp "$root/original/.config/hypr/input.lua" "$hypr/input.lua"

backup_found=false
for backup in "$hypr"/hyprland.lua.macbook-backup.*; do
  if cmp -s "$root/main" "$backup"; then backup_found=true; fi
done
[[ $backup_found == true ]] || { printf 'Original entrypoint backup missing\n' >&2; exit 1; }
unchanged_failure --natural-scroll --screenshot-hotkey keep

for file in .config/hypr/input.lua .config/hypr/bindings.lua .config/fcitx5/profile .config/fcitx5/config .local/share/fcitx5/rime/default.custom.yaml; do
  cmp "$root/original/$file" "$HOME/$file"
done
cmp "$root/original/.config/hypr/hyprland.lua" <(awk '/^-- BEGIN omarchy-macbook-behavior/ { block=1; next } /^-- END omarchy-macbook-behavior/ { block=0; next } !block' "$hypr/hyprland.lua")

before=$(snapshot)
bash "$scripts/recommend-shortcuts.sh" > "$root/audit"
grep -q CUSTOM_LIVE_BIND "$root/audit"
MOCK_HYPR_FAIL=1 bash "$scripts/recommend-shortcuts.sh" > "$root/audit-fallback"
grep -q 'Unavailable' "$root/audit-fallback"
grep -q 'Super+Shift+Q' "$root/audit-fallback"
[[ $(snapshot) == "$before" ]]
if bash "$scripts/recommend-shortcuts.sh" --apply > "$root/output" 2>&1; then
  printf 'Auditor accepted unknown arguments\n' >&2; exit 1
fi

# Exercise real TTY prompts without touching the running desktop.
if command -v script >/dev/null 2>&1; then
  before=$(snapshot)
  printf 'natural\nboth\nsuper-shift-z\nn\n' | script -qec "bash '$scripts/setup.sh'" /dev/null > "$root/tty-decline"
  [[ $(snapshot) == "$before" ]]
  printf 'traditional\nboth\nsuper-shift-z\ny\n' | script -qec "bash '$scripts/setup.sh'" /dev/null > "$root/tty-accept"
  grep -q 'natural_scroll = false' "$hypr/macbook_behavior.lua"
  grep -q 'SUPER + CTRL + A' "$hypr/macbook_behavior.lua"
  grep -q 'SUPER + SHIFT + Z' "$hypr/macbook_behavior.lua"
fi

[[ ! -e $MOCK_LOG ]] || { printf 'Unexpected command invocation\n' >&2; exit 1; }
printf '%s\n' 'PASS: isolated native-wrapper/legacy-omasnap detection, PATH/source mismatches in both directions,' \
  'missing-tool/no-write failures,' \
  '48 preference/backend combinations, shortcut-only legacy install, identical reruns,' \
  'personal/IME preservation, Lua load ordering (if available), live/fallback audit,' \
  'TTY confirmation (if available), and no package/service/system mutation commands.'
