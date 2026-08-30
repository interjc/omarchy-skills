---
name: omarchy-macbook-behavior
description: Configure Omarchy Linux to replicate macOS / MacBook ergonomic trackpad behaviors (three-finger drag, palm rejection, natural scroll), multilingual input methods (Chinese Rime-Ice & Japanese Mozc), sleep/clamshell power optimizations, and desktop hotkeys.
---

# Omarchy MacBook Behavior & Ergonomics Guide 🍏

This skill provides a complete set of configurations, optimizations, and automation scripts to replicate the smooth, ergonomic **macOS and MacBook user experience** on **Omarchy Linux**.

---

## 🎯 Key Objectives

1. **MacBook-Grade Trackpad Ergonomics**:
   - **Three-Finger Drag (`drag_3fg = 1`)**: Replicate macOS Accessibility three-finger drag for seamless window dragging and text selection without physical clicking.
   - **Palm Rejection (`disable_while_typing = true`)**: Automatically disable touchpad response while typing to prevent accidental cursor jumping.
   - **Natural Scrolling (`natural_scroll = true`)**: Directional parity with macOS touchpads.
   - **Clickfinger Behavior (`clickfinger_behavior = true`)**: 1 finger = Left Click, 2 fingers = Right Click, 3 fingers = Middle Click.
   - **Smooth Scrolling Factor**: Optimized velocity curves for desktop and terminal emulators.

2. **Multilingual Input Method (macOS Layout: 中/日/英)**:
   - **Fcitx5 Engine**: Fully integrated with Hyprland and Wayland environments.
   - **Chinese IME**: Powered by `fcitx5-rime` with the **Rime-Ice (雾凇拼音)** dictionary schema.
   - **Japanese IME**: Powered by `fcitx5-mozc` (Google Japanese Input).
   - **macOS Shortcut Parity**:
     - `Control + Space` / `Super + Space`: Toggle and cycle input methods.
     - Single `Shift_L`: Instant English / Chinese inline switching.
   - **macOS Behavior**: Independent input state per application window (`ShareInputState = No`) and clean 5-candidate horizontal pagination.

3. **MacBook Sleep, Lid-Close & Clamshell Management**:
   - **Instant Sleep on Lid Close (合盖即走)**: Automatically locks session and suspends immediately when closing the laptop lid on battery.
   - **External Display Clamshell Mode (蛤壳外接屏模式)**: When docked to an external monitor, closing the lid keeps the session alive, turns off the internal panel, and redirects output seamlessly without sleeping.
   - **Inhibit Delay (`InhibitDelayMaxSec=15`)**: Guarantees the lock screen is fully rendered and secured before hardware ACPI suspend triggers.
   - **Instant Wake & DPMS**: Wakes instantly on keypress or trackpad touch (`key_press_enables_dpms = true`).
   - **Lid-Aware Biometric Gate**: Automatically falls back to password when lid is shut instead of blocking on inaccessible fingerprint sensors.

4. **macOS-Style Shortcuts & Screenshot Workflow**:
   - `ALT + SHIFT + 4` (equivalent to Mac `Cmd + Shift + 4`): Area screenshot with `omasnap`.
   - `PRINT` / `F12`: Fullscreen screenshot.
   - Hyprland layer rules with zero-animation overrides for instant screenshot overlay.

---

## ⚡ Quick Start (Automated Setup)

Run the all-in-one setup script included in this skill:

```bash
bash skills/omarchy-macbook-behavior/scripts/setup.sh
```

---

## 🛠️ Step-by-Step Manual Setup

### 1. Configure Hyprland Trackpad (MacBook Behavior)

Edit `~/.config/hypr/input.lua`:

```lua
-- MacBook Trackpad Ergonomics & Gestures
hl.config({
  input = {
    touchpad = {
      -- Palm rejection: Disable trackpad while typing on keyboard
      disable_while_typing = true,

      -- Natural scrolling direction (macOS style)
      natural_scroll = true,

      -- Left-click-and-drag with three fingers (macOS Accessibility style)
      drag_3fg = 1,

      -- Clickfinger mapping (1 = Left, 2 = Right, 3 = Middle)
      clickfinger_behavior = true,

      -- Tap to click
      tap_to_click = true,

      -- Smooth scrolling velocity
      scroll_factor = 0.4,
    },
  },

  misc = {
    -- Instant wake on input
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
  },
})

-- App-specific scroll speed adjustments
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
```

Reload Hyprland:
```bash
hyprctl reload
```

---

### 2. Configure Sleep, Lid-Close & Clamshell Mode

#### A. Set Logind Inhibit Delay
Ensure display locking finishes before hardware sleep:

Create `/etc/systemd/logind.conf.d/20-inhibit-delay.conf`:
```ini
[Login]
InhibitDelayMaxSec=15
```

#### B. Idle & Auto-Lock Timers
In `~/.config/omarchy/shell.json`, set balanced macOS-style idle timeouts:
```json
{
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

#### C. Clamshell & Lid Switch Hooks
In `~/.config/hypr/bindings.lua` (or via Omarchy defaults), verify lid switch triggers:
```lua
o.bind("switch:on:Lid Switch", nil, "omarchy-system-lid-close", { locked = true })
o.bind("switch:off:Lid Switch", nil, "omarchy-hyprland-monitor-clamshell", { locked = true })
```

---

### 3. Configure macOS-Style Screenshot Shortcuts

In `~/.config/hypr/bindings.lua`, append the screenshot bindings:

```lua
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
```

Reload Hyprland:
```bash
hyprctl reload
```

---

### 4. Install & Configure Fcitx5 (Chinese + Japanese)

#### Install Packages
```bash
sudo pacman -S --needed --noconfirm \
  fcitx5 \
  fcitx5-gtk \
  fcitx5-qt \
  fcitx5-configtool \
  fcitx5-rime \
  fcitx5-mozc \
  git
```

#### Configure Input Method Profile
Create `~/.config/fcitx5/profile`:

```ini
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
```

#### Configure macOS Shortcuts & Behavior
Create `~/.config/fcitx5/config`:

```ini
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
# Single Shift tap to switch between English and Chinese
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

[Behavior]
ActiveByDefault=False
resetStateWhenFocusIn=No
# Independent input method state per window (macOS behavior)
ShareInputState=No
PreeditEnabledByDefault=True
ShowInputMethodInformation=True
CompactInputMethodInformation=True
ShowFirstInputMethodInformation=True
DefaultPageSize=5
AutoSavePeriod=30
```

---

### 5. Deploy Rime-Ice (雾凇拼音) Schema

Rime-Ice provides the most accurate and up-to-date Chinese Pinyin lexicon:

```bash
RIME_DIR="$HOME/.local/share/fcitx5/rime"
mkdir -p "$RIME_DIR"

# Clone rime-ice if not already present
if [ ! -f "$RIME_DIR/rime_ice.schema.yaml" ]; then
  TMP_DIR=$(mktemp -d)
  git clone --depth 1 https://github.com/iDvel/rime-ice.git "$TMP_DIR"
  cp -r "$TMP_DIR"/* "$RIME_DIR/"
  rm -rf "$TMP_DIR"
fi

# Enable rime-ice patch in default config
cat << 'EOF' > "$RIME_DIR/default.custom.yaml"
patch:
  __include: rime_ice_suggestion:/
EOF
```

Restart Fcitx5 to build lexicon dictionaries:
```bash
fcitx5 -r -d 2>/dev/null || true
```

---

## 🔍 Verification & Testing

1. **Test Three-Finger Drag**:
   - Place three fingers on the trackpad over any window titlebar or text block.
   - Move your fingers without pressing down: the window should drag or text should highlight smoothly.
2. **Test Palm Rejection**:
   - Begin typing in a text field while resting your palm or brushing a finger across the trackpad: the cursor should stay stationary.
3. **Test Sleep & Lid Close**:
   - Close the laptop lid on battery $\rightarrow$ screen locks instantly and enters sleep.
   - Connect an external display and close the lid $\rightarrow$ laptop screen turns off while external display stays awake (Clamshell mode).
4. **Test Input Methods**:
   - Press `Control + Space` $\rightarrow$ activates Rime (Chinese Pinyin).
   - Press single `Shift` $\rightarrow$ toggles between English and Chinese inline.
   - Press `Super + Space` $\rightarrow$ cycles to Mozc (Japanese) and English.
5. **Test Area Screenshot**:
   - Press `ALT + SHIFT + 4` $\rightarrow$ `omasnap` area selection overlay appears instantly.

---

## 📁 Reference Files

- [`scripts/setup.sh`](./scripts/setup.sh) — All-in-one setup script.
- [`references/hyprland-input.lua`](./references/hyprland-input.lua) — Hyprland trackpad settings.
- [`references/hyprland-bindings.lua`](./references/hyprland-bindings.lua) — Screenshot and shortcut bindings.
- [`references/logind-inhibit-delay.conf`](./references/logind-inhibit-delay.conf) — Logind sleep delay configuration.
- [`references/fcitx5-profile`](./references/fcitx5-profile) — Input method group profile.
- [`references/fcitx5-config`](./references/fcitx5-config) — Hotkeys and behavior options.
- [`references/rime-default.custom.yaml`](./references/rime-default.custom.yaml) — Rime-Ice patch config.
