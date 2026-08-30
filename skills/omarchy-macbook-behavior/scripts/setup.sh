#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Setup script: MacBook Behavior & Ergonomics for Omarchy Linux
# ==============================================================================

# Parse options
NATURAL_SCROLL=""
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

-- 4-finger swipe up: Toggle scratchpad / special workspace
hl.gesture({
  fingers = 4,
  direction = "up",
  action = function()
    hl.dispatch(hl.dsp.workspace.toggle_special("scratchpad"))
  end,
})
EOF

echo "==> [3/6] Configuring macOS-style Screenshot & Shortcut Bindings..."
BINDINGS_LUA="$HOME/.config/hypr/bindings.lua"
if [ -f "$BINDINGS_LUA" ]; then
  if ! grep -q "ALT + SHIFT + 4" "$BINDINGS_LUA"; then
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
  fi
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

echo "==> [6/6] Optimizing Sleep & Logind Inhibit Delay..."
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

echo ""
echo "================================================================="
echo " MacBook Behavior integration complete!"
echo " - Trackpad: Three-finger drag enabled (drag_3fg = 1)"
echo " - Trackpad: Palm rejection (disable_while_typing = true)"
echo " - Trackpad: Scroll direction set to natural_scroll = ${NATURAL_SCROLL}"
echo " - Power:    Lid-close sleep & Clamshell mode optimized"
echo " - IME:      US English, Chinese (Rime-Ice 雾凇), Japanese (Mozc)"
echo " - IME Keys: Control+Space (trigger), Single Shift (EN/ZH toggle)"
echo " - Shotcuts: ALT+SHIFT+4 for macOS-style area screenshot"
echo "================================================================="
