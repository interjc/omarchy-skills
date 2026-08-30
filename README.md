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

# Or install a specific skill directly
npx skills add interjc/omarchy-skills --skill omarchy-agent-agy
```

---

## 📚 Skills Catalog

| Skill | Description | Status |
| :--- | :--- | :--- |
| [`omarchy-agent-agy`](./skills/omarchy-agent-agy/SKILL.md) | Seamlessly integrate Google Antigravity CLI (`agy`) as Omarchy's default agent and live status bar quota monitor. | `v1.0.0` (Stable) |

---

## 🚀 Featured Skills

### 1. `omarchy-agent-agy` — Antigravity Agent & Status Bar Integration

> **Goal**: Seamlessly replace legacy `gemini` with Google Antigravity CLI (`agy`) across Omarchy's system agent whitelist, Quickshell menus, Hyprland shortcuts, and top status bar.

#### Highlights

1. **Non-Destructive Agent Mapping**:
   - Places a transparent CLI wrapper at `~/.local/bin/gemini` that translates arguments (`--yolo` → `--dangerously-skip-permissions`, `-i`, `-p`) and executes `agy`.
   - Leaves Omarchy's internal agent identifier as `gemini` so system commands (`omarchy agent`, `omarchy-default-agent`) work flawlessly without modifying `/usr/share/omarchy/` or breaking across system updates.

2. **Quickshell Menu Customization**:
   - Overrides `~/.config/omarchy/extensions/omarchy-menu.jsonc` to display **"Antigravity (agy)"** with icon `󰫢` in the Omarchy Setup menu (`SUPER + SPACE`).

3. **24/7 Status Bar Quota Monitoring (`ai-usagebar`)**:
   - Sets up a lightweight headless `systemd` user service (`agy-daemon.service`) running `agy` in `stream-json` mode.
   - Allows `ai-usagebar` and the desktop panel to query real-time 5-hour session and weekly quotas for both Gemini and Claude/GPT models **without needing a terminal window open**.

#### Quick Setup

```bash
# Clone or install the skill, then run the automated setup script:
bash skills/omarchy-agent-agy/scripts/setup.sh
```

For detailed manual instructions and architectural breakdown, see [`skills/omarchy-agent-agy/SKILL.md`](./skills/omarchy-agent-agy/SKILL.md).

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