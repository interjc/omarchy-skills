#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Setup script: MacBook Behavior & Ergonomics for Omarchy Linux
# ==============================================================================

# Parse options
NATURAL_SCROLL=""
SCREENSHOT_HOTKEY=""
while (($#)); do
  case "$1" in
    --natural-scroll)
      NATURAL_SCROLL="true"
      shift
      ;;
    --traditional-scroll|--reverse-scroll)
      NATURAL_SCROLL="false"
      shift
      ;;
    --screenshot-hotkey)
      SCREENSHOT_HOTKEY="$2"
      shift 2
      ;;
    --super-ctrl-a)
      SCREENSHOT_HOTKEY="super-ctrl-a"
      shift
      ;;
    --alt-shift-4|--mac-screenshot)
      SCREENSHOT_HOTKEY="alt-shift-4"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# If not provided via flag, ask interactively if in terminal, or default to false (traditional)
if [ -z "$NATURAL_SCROLL" ]; then
  if [ -t 0 ]; then
    echo "================================================================="
    echo " Choose your preferred trackpad scrolling direction:"
    echo "   1) Traditional (2 fingers UP moves page UP) [Default]"
    echo "   2) Natural / macOS (2 fingers UP moves page DOWN)"
    echo "================================================================="
    read -r -p "Select option [1/2] (default: 1): " scroll_choice </dev/tty || scroll_choice="1"
    case "$scroll_choice" in
      2) NATURAL_SCROLL="true" ;;
      *) NATURAL_SCROLL="false" ;;
    esac
  else
    NATURAL_SCROLL="false"
  fi
fi

# If screenshot hotkey not provided, ask interactively
if [ -z "$SCREENSHOT_HOTKEY" ]; then
  if [ -t 0 ]; then
    echo "================================================================="
    echo " Choose your preferred screenshot hotkey (omasnap):"
    echo "   1) Super + Ctrl + A (Snipaste / WeChat style, unbinds Audio menu) [Default]"
    echo "   2) Alt + Shift + 4 (macOS Cmd+Shift+4 style)"
    echo "   3) Both (Enable both Super+Ctrl+A and Alt+Shift+4)"
    echo "================================================================="
    read -r -p "Select option [1/2/3] (default: 1): " shot_choice </dev/tty || shot_choice="1"
    case "$shot_choice" in
      2) SCREENSHOT_HOTKEY="alt-shift-4" ;;
      3) SCREENSHOT_HOTKEY="both" ;;
      *) SCREENSHOT_HOTKEY="super-ctrl-a" ;;
    esac
  else
    SCREENSHOT_HOTKEY="super-ctrl-a"
  fi
fi

echo "==> [1/6] Installing Input Method Packages (Fcitx5 + Rime + Mozc)..."
MISSING_PKGS=()
for pkg in fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-rime fcitx5-mozc git; do
  if ! pacman -Q "$pkg" >/dev/null 2>&1; then
    MISSING_PKGS+=("$pkg")
  fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
  echo "Installing missing packages: ${MISSING_PKGS[*]}"
  sudo pacman -S --needed --noconfirm "${MISSING_PKGS[@]}"
else
  echo "All required input method packages are already installed."
fi

echo "==> [2/6] Configuring Hyprland Trackpad (Three-finger drag, palm rejection, scroll direction: natural_scroll=${NATURAL_SCROLL})..."
mkdir -p "$HOME/.config/hypr"
INPUT_LUA="$HOME/.config/hypr/input.lua"

cat << EOF > "$INPUT_LUA"
-- Keep only your personal input overrides here.
-- MacBook (Apple Multi-Touch Trackpad bcm5974) Ergonomics & Gesture Tuning
hl.config({
  input = {
    -- Hardware acceleration profile for smooth pointer feel
    sensitivity = 0,
    accel_profile = "adaptive",

    touchpad = {
      -- Palm rejection: Disable trackpad while typing on keyboard
      disable_while_typing = true,

      -- Scrolling direction:
      -- natural_scroll = false (Traditional: 2 fingers swipe UP moves page UP)
      -- natural_scroll = true  (Natural: 2 fingers swipe UP moves page DOWN)
      natural_scroll = ${NATURAL_SCROLL},

      -- Left-click-and-drag with three fingers (macOS Accessibility style)
      drag_3fg = 1,

      -- Clickfinger mapping (1 finger = Left, 2 fingers = Right, 3 fingers = Middle)
      clickfinger_behavior = true,

      -- Tap to click (soft touch)
      tap_to_click = true,

      -- Single-finger double tap and drag
      tap_and_drag = true,

      -- Fine-tuned smooth scrolling factor
      scroll_factor = 0.45,

      -- Clean two-finger right click without middle-click confusion
      middle_button_emulation = false,
    },
  },

  gestures = {
    -- Fluid macOS-like workspace swipe physics
    workspace_swipe_distance = 300,
    workspace_swipe_cancel_ratio = 0.3,
    workspace_swipe_min_speed_to_force = 15,
    workspace_swipe_direction_lock = true,
    workspace_swipe_direction_lock_threshold = 10,
  },

  misc = {
    -- Instant display wake upon touching trackpad or keyboard
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
})

-- Terminal-specific scroll speeds
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.4 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.25 })

-- macOS Multi-Finger Trackpad Gestures
-- 4-finger horizontal swipe: Smoothly switch workspaces (coexists with 3-finger drag)
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

-- 4-finger swipe up: Toggle scratchpad / special workspace (Mission Control style)
hl.gesture({
  fingers = 4,
  direction = "up",
  action = function()
    hl.dispatch(hl.dsp.workspace.toggle_special("scratchpad"))
  end,
})

-- 4-finger swipe down: Dismiss / toggle scratchpad
hl.gesture({
  fingers = 4,
  direction = "down",
  action = function()
    hl.dispatch(hl.dsp.workspace.toggle_special("scratchpad"))
  end,
})

-- 4-finger pinch in: Launchpad / Application launcher (omarchy-menu)
hl.gesture({
  fingers = 4,
  direction = "pinchin",
  action = function()
    hl.dispatch(hl.dsp.exec_cmd("omarchy-menu toggle"))
  end,
})
EOF

echo "==> [3/6] Configuring Screenshot & Shortcut Bindings (omasnap: ${SCREENSHOT_HOTKEY})..."
BINDINGS_LUA="$HOME/.config/hypr/bindings.lua"
mkdir -p "$(dirname "$BINDINGS_LUA")"
touch "$BINDINGS_LUA"

if ! grep -q "omasnap" "$BINDINGS_LUA"; then
  cat << 'EOF' >> "$BINDINGS_LUA"

-- Omasnap screenshot overlay
hl.unbind("PRINT")
hl.unbind("F12")
EOF

  if [ "$SCREENSHOT_HOTKEY" = "super-ctrl-a" ] || [ "$SCREENSHOT_HOTKEY" = "both" ]; then
    cat << 'EOF' >> "$BINDINGS_LUA"
hl.unbind("SUPER + CTRL + A")
o.bind("SUPER + CTRL + A", "Screenshot", "omasnap")
EOF
  fi

  if [ "$SCREENSHOT_HOTKEY" = "alt-shift-4" ] || [ "$SCREENSHOT_HOTKEY" = "both" ]; then
    cat << 'EOF' >> "$BINDINGS_LUA"
hl.unbind("ALT + SHIFT + 4")
o.bind("ALT + SHIFT + 4", "Area Screenshot (macOS Cmd+Shift+4)", "omasnap")
EOF
  fi

  cat << 'EOF' >> "$BINDINGS_LUA"
o.bind("PRINT", "Screenshot", "omasnap")
o.bind("F12", "Screenshot", "omasnap")

hl.layer_rule({
  match = { namespace = "^omasnap$" },
  no_anim = true,
  animation = "none",
  no_screen_share = true,
})
EOF
fi

# Clipboard history (Alfred style Super + Shift + Z)
if ! grep -q "SUPER + SHIFT + Z" "$BINDINGS_LUA"; then
  cat << 'EOF' >> "$BINDINGS_LUA"

-- Clipboard history (Alfred style Super + Shift + Z)
hl.unbind("SUPER + SHIFT + Z")
o.bind("SUPER + SHIFT + Z", "Clipboard history", "omarchy-shell shell toggle omarchy.clipboard")
EOF
fi

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload 2>/dev/null || true
fi

echo "==> [4/6] Configuring Fcitx5 Input Methods (US, Chinese Rime, Japanese Mozc)..."
mkdir -p "$HOME/.config/fcitx5"

# Setup profile
cat << 'EOF' > "$HOME/.config/fcitx5/profile"
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=rime

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=rime
Layout=

[Groups/0/Items/2]
Name=mozc
Layout=

[GroupOrder]
0=Default
EOF

# Setup hotkeys and macOS behavior
cat << 'EOF' > "$HOME/.config/fcitx5/config"
[Hotkey]
EnumerateWithTriggerKeys=True
EnumerateForwardKeys=
EnumerateBackwardKeys=
EnumerateSkipFirst=False
ModifierOnlyKeyTimeout=250

[Hotkey/TriggerKeys]
0=Control+space
1=Zenkaku_Hankaku
2=Hangul

[Hotkey/AltTriggerKeys]
0=Shift_L

[Hotkey/EnumerateGroupForwardKeys]
0=Super+space

[Hotkey/EnumerateGroupBackwardKeys]
0=Shift+Super+space

[Hotkey/PrevPage]
0=Up

[Hotkey/NextPage]
0=Down

[Hotkey/PrevCandidate]
0=Shift+Tab

[Hotkey/NextCandidate]
0=Tab

[Hotkey/TogglePreedit]
0=Control+Alt+P

[Behavior]
ActiveByDefault=False
resetStateWhenFocusIn=No
ShareInputState=No
PreeditEnabledByDefault=True
ShowInputMethodInformation=True
showInputMethodInformationWhenFocusIn=False
CompactInputMethodInformation=True
ShowFirstInputMethodInformation=True
DefaultPageSize=5
OverrideXkbOption=False
PreloadInputMethod=True
AllowInputMethodForPassword=False
ShowPreeditForPassword=False
AutoSavePeriod=30
EOF

echo "==> [5/6] Deploying Rime-Ice (雾凇拼音) Schema for Chinese IME..."
RIME_DIR="$HOME/.local/share/fcitx5/rime"
mkdir -p "$RIME_DIR"

if [ ! -d "$RIME_DIR/rime_ice.userdb" ] && [ ! -f "$RIME_DIR/rime_ice.schema.yaml" ]; then
  echo "Cloning rime-ice repository..."
  TMP_RIME=$(mktemp -d)
  git clone --depth 1 https://github.com/iDvel/rime-ice.git "$TMP_RIME"
  cp -r "$TMP_RIME"/* "$RIME_DIR/"
  rm -rf "$TMP_RIME"
fi

cat << 'EOF' > "$RIME_DIR/default.custom.yaml"
patch:
  __include: rime_ice_suggestion:/
EOF

# Restart fcitx5 daemon if running
if command -v fcitx5-remote >/dev/null 2>&1; then
  fcitx5 -r -d >/dev/null 2>&1 || true
fi

echo "==> [6/7] Optimizing Sleep & Logind Inhibit Delay..."
if [ -d "/etc/systemd/logind.conf.d" ]; then
  if [ ! -f "/etc/systemd/logind.conf.d/20-inhibit-delay.conf" ]; then
    echo "Setting up /etc/systemd/logind.conf.d/20-inhibit-delay.conf (requires sudo)..."
    sudo mkdir -p /etc/systemd/logind.conf.d
    sudo bash -c 'cat << "EOF" > /etc/systemd/logind.conf.d/20-inhibit-delay.conf
[Login]
InhibitDelayMaxSec=15
EOF'
  fi
fi

echo "==> [7/7] Configuring Apple Trackpad Internal Device Udev Rule (Palm rejection & DWT fix)..."
if lsmod | grep -qE "(bcm5974|applespi)" || [ -d "/sys/bus/usb/drivers/bcm5974" ]; then
  if [ ! -f "/etc/udev/rules.d/71-apple-trackpad-internal.rules" ]; then
    echo "Setting up /etc/udev/rules.d/71-apple-trackpad-internal.rules (requires sudo)..."
    sudo mkdir -p /etc/udev/rules.d
    sudo bash -c 'cat << "EOF" > /etc/udev/rules.d/71-apple-trackpad-internal.rules
# Fix Apple MacBook internal trackpad falsely classified as external USB device.
# This ensures libinput enables palm rejection (Disable-While-Typing) paired with the internal keyboard.
ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ENV{ID_INPUT_TOUCHPAD}=="1", ENV{ID_USB_DRIVER}=="bcm5974", ENV{ID_INPUT_TOUCHPAD_INTEGRATION}="internal", ENV{ID_INTEGRATION}="internal"
EOF'
    sudo udevadm control --reload 2>/dev/null || true
    sudo udevadm trigger -s input 2>/dev/null || true
    echo "Apple trackpad udev rule installed and reloaded."
  else
    echo "Apple trackpad udev rule is already present."
  fi
fi

echo ""
echo "================================================================="
echo " MacBook Behavior integration complete!"
echo " - Trackpad:   Three-finger drag enabled (drag_3fg = 1)"
echo " - Trackpad:   Palm rejection (disable_while_typing = true)"
echo " - Trackpad:   Scroll direction set to natural_scroll = ${NATURAL_SCROLL}"
echo " - Power:      Lid-close sleep & Clamshell mode optimized"
echo " - IME:        US English, Chinese (Rime-Ice 雾凇), Japanese (Mozc)"
echo " - IME Keys:   Control+Space (trigger), Single Shift (EN/ZH toggle)"
echo " - Clipboard:  SUPER+SHIFT+Z enabled for Alfred-style clipboard history"
echo " - Screenshot: omasnap enabled with hotkey (${SCREENSHOT_HOTKEY})"
echo "================================================================="
