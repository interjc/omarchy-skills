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
| [`omarchy-agent-agy`](./skills/omarchy-agent-agy/SKILL.md) | Select native `agy` or approved legacy compatibility by detected capabilities, with an optional usage bar. | Packaged script regression test on `4.5.0-3` and historical live tests on `4.0.6-1` |
| [`omarchy-macbook-behavior`](./skills/omarchy-macbook-behavior/SKILL.md) | Add confirmed Lua trackpad and shortcut overrides, with manual input method, power, and hardware diagnostics. | Configuration audit and sandbox tests on `4.5.0-3`, with historical live tests on `4.0.6-1` |

---

## Compatibility & Verification

The **2026-11-22** local audit used Omarchy **`4.5.0-3`** and Hyprland **`0.56.2-4`**. The installers select their paths based on the installed implementations.

| Area | Installed `4.5.0-3` | Historical `4.0.6-1` |
| :--- | :--- | :--- |
| Agent dispatch/default | Native `agy --dangerously-skip-permissions`, and the setter normalizes aliases such as `gemini` to `agy` | `gemini --yolo`, and the setter rejects `agy` |
| Default menu entry | `setup.default.agent.agy` | `setup.default.agent.gemini` |
| Screenshot entry point | The official wrapper invokes Omasnap with notifications | The official wrapper uses the older capture flow, and a separately installed `omasnap` can be used |
| Hyprland workflow | Ships native input method shortcuts, and the installed defaults do not read the gesture-disable flag | Lua configuration without native input method shortcuts or the default gesture module |

The 4.5 audit checked installed source, effective shortcuts, trackpad values, and user services. A follow-up verified shortcut migration and native input method cycling. Sandboxed tests cover native Agent dispatch and gesture configuration migration. The [bilingual validation record](VALIDATION.md) includes the 4.5 results and older live tests. [Omarchy 4.5.0 release](https://github.com/omacom/omarchy/releases/tag/v4.5.0)

---

## 🚀 Featured Skills

### 1. `omarchy-agent-agy`: Antigravity Agent & Optional Usage Bar

> **Goal**: Prefer Omarchy's native Antigravity CLI (`agy`) support, using a Gemini shim only on detected, known legacy implementations with explicit approval.

#### Highlights
- **Detect Before Choosing**: Inspect the installed dispatcher and setter capabilities; use `omarchy-default-agent agy` natively, require separate approval for the legacy shim, and reject unknown implementations. Both native dispatch and the legacy shim bypass agent permission prompts.
- **Scoped Installer**: Handles only approved default-agent mapping and the optional user service. It does not edit menus, shortcuts, usage-bar configuration, or `shell.json`, or write to `/usr/share/omarchy/` or `/etc`. The native setter may install a tool through mise and launch a terminal; check `agy` installation and authentication first.
- **Quota and Background Session**. ai-usagebar `1.52.3` can query quota through a signed-in `agy -p "/quota"`. Enable the optional `stream-json` user service only when needed and verify quota access separately.
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
- **Managed Lua Overrides**. Choosing a scroll direction also enables three-finger drag, disable-while-typing, and replacement four-finger gestures. Setup sets the disable flag only when the installed defaults read it, backs up changes, manages a separate module and marked blocks, and preserves personal `input.lua`/`bindings.lua`.
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

## 🧩 Recommended Plugins & Setup

The recommendations below are curated from an `omarchy 4.5.0-3` + MacBook daily setup (covering only actively enabled, day-to-day components).

### 1. Third-Party Bar Plugins (Omarchy Shell)

| Plugin | Replaces / Enhances | Highlights | Repository |
| :--- | :--- | :--- | :--- |
| **Spaces** (`tornikegomareli.spaces`) | Replaces stock `omarchy.workspaces` | Shows open app icons directly in each workspace on the top bar; hovering another workspace opens a live window layout preview with click-to-jump thumbnails | [tornikegomareli/omarchy-spaces](https://github.com/tornikegomareli/omarchy-spaces) |
| **Omaplug** (`omaplug`) | Adds GUI management for third-party plugins | Enable/disable, check for updates on a schedule, batch-update, install from git, or remove third-party plugins directly from the top bar and Omarchy menu (`apps.omaplug`), with Marketplace access | [fross100/omaplug](https://github.com/fross100/omaplug) |
| **AI Usage** (`akitaonrails.ai-usagebar` + `ai-usagebar-bin`) | Multi-provider AI quota bar monitor | Tracks subscription usage, balances, and reset countdowns across Antigravity, OpenAI, Claude, and other providers in one panel (see [`omarchy-agent-agy`](./skills/omarchy-agent-agy/SKILL.md)) | [akitaonrails/ai-usagebar](https://github.com/akitaonrails/ai-usagebar) |

### 2. Practical Standalone Tools & Services

| Tool / Service | Purpose | Recommended Usage & Notes | Project |
| :--- | :--- | :--- | :--- |
| **HyprCaffeine** | Idle, lock, and lid-close inhibition for Hyprland / Wayland | Restores inhibitor state on session start via `hyprcaffeine.service` and binds hotkeys to toggle idle, monitor keep-awake, and lid inhibit | [hbuddenberg/hyprcaffeine](https://github.com/hbuddenberg/hyprcaffeine) |
| **Voxtype** | Offline push-to-talk speech-to-text daemon | Set output mode to `clipboard` (paste from system clipboard) to avoid synthetic keystrokes interfering with terminals or input methods | [voxtype.io](https://voxtype.io) |
| **Fcitx5 + Rime (Rime-Ice) + Mozc** | Multilingual CJK / English input stack | Pairs with stock `omarchy-fcitx5.service` and one-way `SUPER + I` cycling (see [`omarchy-macbook-behavior`](./skills/omarchy-macbook-behavior/SKILL.md)) | [iDvel/rime-ice](https://github.com/iDvel/rime-ice) |

### 3. Stock Widgets & Configuration Tweaks Worth Enabling

- **Built-in Bar Widgets & Transparent Bar** (`~/.config/omarchy/shell.json`): Enable `omarchy.elsewhen` (multi-timezone world clock), `omarchy.weather`, `omarchy.monitor` (quick display control), and `bar.transparent: true` as needed.
- **MacBook Trackpad Anti-Accidental-Touch & Selection**: Keep `~/.config/hypr/input.lua` minimal so Omarchy 4.5's stock scroll and terminal/TUI rules stay active; setting `tap_to_click = false` and `tap_and_drag = false` with stock `clickfinger_behavior = true` (physical press clicking) and 3-finger horizontal workspace swipes prevents palm clicks and accidental large text selections. On older USB MacBooks (`bcm5974`) misclassified by `udev` as `ID_INPUT_TOUCHPAD_INTEGRATION=external`, add a targeted `/etc/udev/hwdb.d/71-touchpad-local.hwdb` match for the device's `vid`/`pid` as `internal` to restore libinput disable-while-typing (DWT) and edge palm rejection.
- **Retina HiDPI Scaling & Zero-Latency Screenshots**: Set `scale = 2` and `GDK_SCALE = 2` in `~/.config/hypr/monitors.lua`; add a `^omasnap$` layer rule with `no_anim = true` and `animation = "none"` in `~/.config/hypr/bindings.lua` to eliminate capture overlay animation delay (never add `no_screen_share` for `omasnap`, which breaks scrolling capture).

> ⚠️ **Safety & Config Notes**: Third-party plugins and AUR packages execute unsandboxed code—review their source or package definitions before installing. `~/.config/omarchy/shell.json` is a complete configuration file rather than a partial deep-merge override, so always back it up and edit it in place.

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
