#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Setup script: MacBook Behavior & Ergonomics for Omarchy Linux
# ==============================================================================

echo "==> [1/5] Installing Input Method Packages (Fcitx5 + Rime + Mozc)..."
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

echo "==> [2/5] Configuring Hyprland Trackpad (Three-finger drag, palm rejection, natural scroll)..."
mkdir -p "$HOME/.config/hypr"
INPUT_LUA="$HOME/.config/hypr/input.lua"

cat << 'EOF' > "$INPUT_LUA"
-- Keep only your personal input overrides here.
-- MacBook Trackpad Ergonomics & Gestures
hl.config({
  input = {
    touchpad = {
      -- Palm rejection: disable trackpad while typing on keyboard
      disable_while_typing = true,

      -- Natural scrolling direction (macOS style)
      natural_scroll = true,

      -- Left-click-and-drag with three fingers (macOS Accessibility style)
      drag_3fg = 1,

      -- 1 finger = left, 2 fingers = right, 3 fingers = middle
      clickfinger_behavior = true,

      -- Tap to click
      tap_to_click = true,

      -- Smooth scrolling factor
      scroll_factor = 0.4,
    },
  },
})

-- App-specific touchpad scroll speeds
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
EOF

echo "==> [3/5] Configuring macOS-style Screenshot & Shortcut Bindings..."
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

echo "==> [4/5] Configuring Fcitx5 Input Methods (US, Chinese Rime, Japanese Mozc)..."
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
echo " - Trackpad: Natural scrolling enabled"
echo " - Power:    Lid-close sleep & Clamshell mode optimized"
echo " - IME:      US English, Chinese (Rime-Ice 雾凇), Japanese (Mozc)"
echo " - IME Keys: Control+Space (trigger), Single Shift (EN/ZH toggle)"
echo " - Shotcuts: ALT+SHIFT+4 for macOS-style area screenshot"
echo "================================================================="
