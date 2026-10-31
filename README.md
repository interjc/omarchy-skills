<div align="right">

[English](README.md) | [简体中文](README_ZH.md)

</div>

# Omarchy Skills 🧙‍♂️

A curated collection of AI agent skills, user-level customizations, and workflow automations for **[Omarchy Linux](https://omarchy.org)**.

Developed and maintained by **Justin** ([@interjc](https://x.com/interjc) · [interjc.net](https://interjc.net)).

---

## 🌟 About

**Omarchy Skills** turns everyday Omarchy configuration experience and desktop workflows into modular skills for assistants such as Antigravity, Claude Code, and Codex. Inspect the installed version and personal configuration first, confirm preferences, then apply only approved changes.

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

| Skill | Description | Verification Scope |
| :--- | :--- | :--- |
| [`omarchy-agent-agy`](./skills/omarchy-agent-agy/SKILL.md) | Select native `agy` or approved legacy compatibility by detected capabilities; background session and usage bar are optional. | Sandbox tests; legacy mapping, service, and quota tested on `4.0.6-1` |
| [`omarchy-macbook-behavior`](./skills/omarchy-macbook-behavior/SKILL.md) | Add confirmed Lua trackpad/shortcut overrides; input methods, power, and hardware diagnostics remain separate manual steps. | Sandbox tests; shortcut loading and screenshot output tested on `4.0.6-1` |

---

## Compatibility & Verification

**Audit snapshot: 2026-10-31.** The stable tag **`v4.0.6`** and default branch **`quattro`** at **`bda3aaf6955404712dbd46541e6c8a75a2b16b7c`** were checked separately. Development-branch capabilities are not treated as shipped stable features.

| Area | `v4.0.6` | Pinned `quattro` Snapshot |
| :--- | :--- | :--- |
| Agent dispatch/default | `gemini --yolo`; default setter rejects `agy` | Native `agy --dangerously-skip-permissions`; aliases including `gemini` normalize to `agy` |
| Default menu entry | `setup.default.agent.gemini` | `setup.default.agent.agy` |
| Screenshot entrypoint | Installed wrapper still uses the older capture flow; retain installed `omasnap` | Official wrapper invokes Omasnap; prefer the wrapper |
| Hyprland workflow | Lacks the snapshot's default-gesture switch and native IME bindings | MacBook automation targets this Lua configuration; older `.conf` setups need separate review |

Pinned upstream evidence: [stable dispatcher](https://github.com/basecamp/omarchy/blob/v4.0.6/bin/omarchy-agent), [default setter](https://github.com/basecamp/omarchy/blob/v4.0.6/bin/omarchy-default-agent); [snapshot dispatcher](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/bin/omarchy-agent), [default setter](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/bin/omarchy-default-agent), [Lua defaults](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/default/hypr/omarchy.lua), [desktop bindings](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/default/hypr/bindings/utilities.lua), [IME bindings](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/default/hypr/bindings/input-method.lua).

Source review, Shell/Lua syntax checks, and sandbox tests using temporary `HOME` directories and mocked commands passed. With approval, both installers were also run on a `4.0.6-1` machine to verify legacy Agent dispatch, service initialization, a quota query with a separate cache, shortcut loading, and non-black PNG output. Gesture feel, scrolling capture, complete IME interaction, suspend security, and the native `quattro` desktop remain untested; this is not full-feature stability certification. See the [bilingual validation record](VALIDATION.md) for the environment, commands, backups, and explicit boundaries.

---

## 🚀 Featured Skills

### 1. `omarchy-agent-agy`: Antigravity Agent & Optional Usage Bar

> **Goal**: Prefer Omarchy's native Antigravity CLI (`agy`) support, using a Gemini shim only on detected, known legacy implementations with explicit approval.

#### Highlights
- **Detect Before Choosing**: Inspect the installed dispatcher and setter capabilities; use `omarchy-default-agent agy` natively, require separate approval for the legacy shim, and reject unknown implementations. Both native dispatch and the legacy shim bypass agent permission prompts.
- **Scoped Installer**: Handles only approved default-agent mapping and the optional user service. It does not edit menus, shortcuts, usage-bar configuration, or `shell.json`, or write to `/usr/share/omarchy/` or `/etc`. The native setter may install a tool through mise and launch a terminal; check `agy` installation and authentication first.
- **Experimental Background Session**: The `stream-json` user service is separately opt-in. It guarantees neither a quota endpoint, continuous availability, zero CPU, nor a fixed memory footprint; an active service is not proof of a successful quota query.
- **Manual Optional Integration**: Review and approve `ai-usagebar` packages, plugins, complete bar layouts, and legacy menu renaming separately. Merge using the skill instructions rather than overwriting personal configuration. Preserve stock `SUPER + SHIFT + CTRL + A` → `omarchy-agent --pick`.

```bash
# Confirm default-agent and background-service choices interactively; specify both for automation
bash skills/omarchy-agent-agy/scripts/setup.sh
```

---

### 2. `omarchy-macbook-behavior`: MacBook Trackpad & Shortcut Preferences

> **Goal**: Add small, optional trackpad and shortcut overrides to the existing Omarchy desktop, not replace its stack or guarantee macOS behavior.

#### Highlights
- **Preferences First**: Choose natural scrolling, traditional scrolling, or keep trackpad behavior, then choose screenshot and clipboard shortcuts separately. Terminals prompt for confirmation; noninteractive runs require every choice explicitly.
- **Managed Lua Overrides**: Choosing a scroll direction also enables three-finger drag, disable-while-typing, and replacement four-finger gestures while disabling upstream default gestures. Manage only a separate module and marked entrypoint blocks, back up changes, and preserve personal `input.lua`/`bindings.lua`; drag feel and palm rejection still require hardware validation.
- **Audit Shortcuts First**: The read-only script separates live bindings from the upstream snapshot. Snapshot screenshot defaults are `Print` / `SUPER + CTRL + ALT + C` (not F12), and clipboard history is `SUPER + CTRL + V`. Optional `SUPER + CTRL + A` screenshots replace Audio, `ALT + SHIFT + 4` is an alternative chord, and `SUPER + SHIFT + Z` is only an optional clipboard alias. Inspect the actual wrapper on PATH: use `omarchy-capture-screenshot` only when it invokes Omasnap; otherwise retain installed `omasnap` on older systems.
- **Separate IME Choices**: The snapshot natively uses `SUPER + I` / `SUPER + SHIFT + I` to cycle input languages, `SUPER + SPACE` for the menu, and `CTRL + SPACE` as a non-consuming terminal-prefix helper. Prefer the native configurator for Mozc; merge Rime/Rime-Ice manually if requested. Cycling groups does not cycle engines within a group.
- **Not an All-in-One Installer**: No package installation, system-directory writes, or Fcitx/Rime, power, udev, logind, or idle-timer configuration. Inspect native lid/clamshell behavior first; optional manual steps require separate diagnosis and approval. Earlier skill changes are not undone automatically.

```bash
# Read-only shortcut audit
bash skills/omarchy-macbook-behavior/scripts/recommend-shortcuts.sh

# Configure only confirmed trackpad and shortcut preferences
bash skills/omarchy-macbook-behavior/scripts/setup.sh
```

These paths assume the repository root. After installing through the skills CLI, run `scripts/setup.sh` from the actual installed skill directory. See each `SKILL.md` for full options, manual steps, verification, and rollback.

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
