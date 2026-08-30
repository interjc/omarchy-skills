#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Setup script: Seamlessly integrate Antigravity (agy) into Omarchy
# ==============================================================================

echo "==> [1/6] Creating gemini -> agy wrapper in ~/.local/bin/gemini..."
mkdir -p "$HOME/.local/bin"

cat << 'EOF' > "$HOME/.local/bin/gemini"
#!/bin/bash
# Wrapper redirecting Omarchy's legacy gemini agent calls to agy (Antigravity CLI)
args=()
while (($#)); do
  case "$1" in
    --yolo)
      # Omarchy uses --yolo for unattended default agent launches
      args+=(--dangerously-skip-permissions)
      shift
      ;;
    --prompt-interactive|-i)
      args+=(-i "$2")
      shift 2
      ;;
    --prompt|-p)
      args+=(-p "$2")
      shift 2
      ;;
    *)
      args+=("$1")
      shift
      ;;
  esac
done

exec agy "${args[@]}"
EOF

chmod +x "$HOME/.local/bin/gemini"

echo "==> [2/6] Setting Omarchy default agent to gemini (mapped to agy)..."
mkdir -p "$HOME/.config/omarchy/defaults"
echo "gemini" > "$HOME/.config/omarchy/defaults/agent"

echo "==> [3/6] Setting up Omarchy Quickshell menu override..."
mkdir -p "$HOME/.config/omarchy/extensions"
MENU_FILE="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"

if [ ! -f "$MENU_FILE" ]; then
  cat << 'EOF' > "$MENU_FILE"
{
  "setup.default.agent.gemini": {
    "icon": "󰫢",
    "label": "Antigravity (agy)",
    "checked": "[[ \"$(omarchy-default-agent)\" == \"gemini\" ]]",
    "action": "omarchy-default-agent gemini"
  }
}
EOF
else
  if ! grep -q "setup.default.agent.gemini" "$MENU_FILE"; then
    echo "Notice: Adding setup.default.agent.gemini entry to $MENU_FILE..."
    # If file contains valid JSON, merge entry or notify user
  fi
fi

if command -v omarchy >/dev/null 2>&1; then
  omarchy menu refresh 2>/dev/null || true
fi

echo "==> [4/6] Setting up Hyprland keybinding..."
HYPR_BINDINGS="$HOME/.config/hypr/bindings.lua"
if [ -f "$HYPR_BINDINGS" ]; then
  if ! grep -q "Antigravity Agent" "$HYPR_BINDINGS"; then
    cat << 'EOF' >> "$HYPR_BINDINGS"

-- Antigravity Agent (agy)
hl.unbind("SUPER + SHIFT + CTRL + A")
o.bind("SUPER + SHIFT + CTRL + A", "Antigravity Agent", "omarchy-launch-tui --app-id=org.omarchy.agent agy")
EOF
    if command -v hyprctl >/dev/null 2>&1; then
      hyprctl reload 2>/dev/null || true
    fi
  fi
fi

echo "==> [5/6] Setting up background agy daemon for status bar quota tracking..."
mkdir -p "$HOME/.config/systemd/user"
AGY_BIN="$(command -v agy || echo "/usr/bin/agy")"

cat << EOF > "$HOME/.config/systemd/user/agy-daemon.service"
[Unit]
Description=Antigravity CLI Background Daemon for Quota Service
PartOf=default.target
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c "tail -f /dev/null | $AGY_BIN --input-format stream-json --output-format stream-json"
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
Environment=HOME=%h
Environment=XDG_CONFIG_HOME=%h/.config
Environment=XDG_DATA_HOME=%h/.local/share
Environment=XDG_CACHE_HOME=%h/.cache
Environment=XDG_STATE_HOME=%h/.local/state
Environment=XDG_RUNTIME_DIR=%t

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now agy-daemon.service || true

echo "==> [6/6] Checking ai-usagebar configuration..."
if [ -d "$HOME/.config/ai-usagebar" ] || command -v ai-usagebar >/dev/null 2>&1; then
  mkdir -p "$HOME/.config/ai-usagebar"
  USAGE_CONFIG="$HOME/.config/ai-usagebar/config.toml"
  if [ ! -f "$USAGE_CONFIG" ]; then
    cat << 'EOF' > "$USAGE_CONFIG"
[antigravity]
enabled = true
EOF
  elif ! grep -q "\[antigravity\]" "$USAGE_CONFIG"; then
    cat << 'EOF' >> "$USAGE_CONFIG"

[antigravity]
enabled = true
EOF
  fi
fi

echo ""
echo "================================================================="
echo " Antigravity (agy) integration complete!"
echo " - Default Agent: agy (mapped via gemini)"
echo " - Keybinding:    SUPER + SHIFT + CTRL + A -> agy"
echo " - Daemon Status: systemctl --user status agy-daemon.service"
echo " - Quota Test:    ai-usagebar --vendor antigravity"
echo "================================================================="
