<div align="right">

[English](README.md) | [简体中文](README_ZH.md)

</div>

# Omarchy Skills 🧙‍♂️

A curated collection of production-ready AI agent skills, system customizations, and workflow automations tailored for **[Omarchy Linux](https://omarchy.org)**.

Developed and maintained by **Justin** ([@interjc](https://x.com/interjc) · [interjc.net](https://interjc.net)).

---

## 🌟 About

**Omarchy Skills** turns real-world Linux power-user experiences, system configurations, and desktop workflows into modular, reusable AI skills. Agentic coding assistants (such as Antigravity, Claude Code, Codex, etc.) can discover, load, and execute these skills to automate complex system integrations and keep your Omarchy environment running at peak performance.

---

## 📦 Quick Installation

The recommended way to install skills from this repository is via `npx skills`:

```bash
# Add all skills from this repository
npx skills add interjc/omarchy-skills

# Or install specific skills directly
npx skills add interjc/omarchy-skills --skill omarchy-agent-agy
npx skills add interjc/omarchy-skills --skill omarchy-macbook-behavior
```

---

## 📚 Skills Catalog

| Skill | Description | Status |
| :--- | :--- | :--- |
| [`omarchy-agent-agy`](./skills/omarchy-agent-agy/SKILL.md) | Seamlessly integrate Google Antigravity CLI (`agy`) as Omarchy's default agent and live status bar quota monitor. | `v1.0.0` (Stable) |
| [`omarchy-macbook-behavior`](./skills/omarchy-macbook-behavior/SKILL.md) | Replicate macOS & MacBook ergonomics: three-finger drag, palm rejection, multilingual IME (ZH/JA/EN), and hotkeys. | `v1.0.0` (Stable) |

---

## 🚀 Featured Skills

### 1. `omarchy-agent-agy` — Antigravity Agent & Status Bar Integration

> **Goal**: Seamlessly replace legacy `gemini` with Google Antigravity CLI (`agy`) across Omarchy's system agent whitelist, Quickshell menus, Hyprland shortcuts, and top status bar.

#### Highlights
- **Non-Destructive Agent Mapping**: Places a transparent CLI wrapper at `~/.local/bin/gemini` that translates arguments (`--yolo` → `--dangerously-skip-permissions`, `-i`, `-p`) and executes `agy` without modifying system files.
- **Quickshell Menu Customization**: Overrides `~/.config/omarchy/extensions/omarchy-menu.jsonc` to display **"Antigravity (agy)"** with icon `󰫢` in the Omarchy Setup menu.
- **24/7 Status Bar Quota Monitoring (`ai-usagebar`)**: Sets up a lightweight headless `systemd` user service (`agy-daemon.service`) running `agy` in `stream-json` mode (zero idle CPU) to query real-time quotas without keeping a terminal open.

```bash
bash skills/omarchy-agent-agy/scripts/setup.sh
```

---

### 2. `omarchy-macbook-behavior` — MacBook Ergonomics & Muscle Memory

> **Goal**: Bring the intuitive touchpad gestures, multilingual input methods, and screenshot workflows of macOS / MacBook to Omarchy Linux.

#### Highlights
- **Trackpad Ergonomics & Gestures**:
  - **Three-Finger Drag (`drag_3fg = 1`)**: Replicate macOS Accessibility three-finger drag to move windows and select text effortlessly without clicking.
  - **Palm Rejection (`disable_while_typing = true`)**: Automatically disable touchpad response while typing to prevent accidental cursor jumping.
  - **Natural Scrolling (`natural_scroll = true`)**: Directional parity with macOS touchpads.
  - **Clickfinger Behavior**: 1 finger = Left Click, 2 fingers = Right Click, 3 fingers = Middle Click.
- **macOS Multilingual Input Methods (Fcitx5 + Rime-Ice + Mozc)**:
  - **Chinese**: `fcitx5-rime` integrated with the **Rime-Ice (雾凇拼音)** lexicon schema.
  - **Japanese**: `fcitx5-mozc` (Google Japanese Input engine).
  - **Keyboard Shortcut Parity**: `Control + Space` to activate, single `Shift_L` tap for inline English/Chinese switching, `Super + Space` to cycle groups.
  - **Independent Window State (`ShareInputState = No`)**: Each application independently remembers its IME status.
- **MacBook Sleep & Clamshell Management**:
  - **Lid-Close Sleep**: Instantly locks session and enters suspend on battery when the laptop lid shuts; wakes immediately on touch.
  - **Clamshell Mode**: Seamlessly switches output and keeps external monitors awake without sleeping when docked.
  - **Logind Inhibit Delay (`InhibitDelayMaxSec=15`)**: Ensures display security lock completes before hardware sleep.
- **Customizable Screenshot Tool & Hotkeys (`omasnap`)**:
  - Zero-latency Wayland overlay screenshot tool `omasnap` with region selection, pin, annotation, and instant clipboard copying.
  - **Snipaste / WeChat Style (`SUPER + CTRL + A`)**: Automatically unbinds Omarchy's low-frequency default Audio panel hotkey to resolve shortcut conflicts.
  - **macOS Style (`ALT + SHIFT + 4`)**: Direct muscle memory equivalent to Mac `Cmd + Shift + 4`.
- **Alfred-Style Clipboard History & Hotkeys**:
  - **Universal Copy & Paste**: `SUPER + C` and `SUPER + V` align system-wide with macOS `Cmd + C` / `Cmd + V`.
  - **Alfred Clipboard History (`SUPER + SHIFT + Z`)**: Replicates Alfred's `Cmd + Shift + Z` muscle memory to invoke the native `omarchy.clipboard` manager for instant history search and one-click paste.
- **Built-in Shortcut Auditor & Ergonomic Recommendations**:
  - Integrated auditing script (`recommend-shortcuts.sh`) that lists default Omarchy shortcuts with ergonomic analysis.
  - Strict 3-step workflow: inspect current bindings $\rightarrow$ recommend ergonomic, conflict-free combinations $\rightarrow$ apply only after explicit user confirmation.

```bash
# Shortcut auditing & interactive recommendation
bash skills/omarchy-macbook-behavior/scripts/recommend-shortcuts.sh

# Full environment setup
bash skills/omarchy-macbook-behavior/scripts/setup.sh
```

---

## 🗺️ Roadmap & Future Skills

- [ ] **Omarchy Waybar & Quickshell Toolkit**: Custom widgets for AI agent metrics, GPU stats, and workspace indicators.
- [ ] **Hyprland AI Productivity Workflows**: Floating scratchpads, dynamic window layouts, and modal AI hotkeys.
- [ ] **Dotfiles & Sync Automation**: Automated backup and synchronization recipes for Omarchy configs.
- [ ] **Local LLM & Ollama / llama.cpp Integration**: Native status bar hooks and fast-switching for offline models.

---

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guide (CONTRIBUTING.md)](./CONTRIBUTING.md) for details on our code of conduct, skill authoring guidelines, and the bilingual documentation workflow.

---

## 👤 Author

**Justin**
- 𝕏 (Twitter): [@interjc](https://x.com/interjc)
- 🌐 Website: [interjc.net](https://interjc.net)
- 🐙 GitHub: [@interjc](https://github.com/interjc)

---

## 📄 License

This repository is licensed under the [MIT License](./LICENSE).