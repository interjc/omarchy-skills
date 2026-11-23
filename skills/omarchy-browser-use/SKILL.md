---
name: omarchy-browser-use
description: Set up opencode browse with the Chrome extension on Omarchy Linux so AI agents can drive your real local Chrome-family browser over both MCP and CLI for local development, including pairing, debugging, and safety boundaries.
---

[English](SKILL.md) | [简体中文](SKILL_ZH.md)

# Omarchy Local Dev Browser Use (`browse` + Chrome)

## Background & Scope

When debugging local web apps, headless browsers (Playwright/Puppeteer) lack your real sign-ins, cookies, and extensions, while IDE-embedded preview tabs stay isolated from your daily Chrome session.

This skill documents a user-level setup verified live on **Omarchy `4.5.0-3` (2026-11-23)**: using [`opencode.ai/browse`](https://opencode.ai/browse) (tested with `0.1.5`), a lightweight local relay (`http://127.0.0.1:19988`) connects to your real Chrome-family browser through the Chrome extension and exposes **both an MCP server (`browse mcp`) and a direct CLI (`browse <tool>`)** to AI agents.

### Architecture & Non-Destructive Design

- **Strictly User-Space**: Writes only to `~/.local/bin/browse`, `~/.config/browse`, `~/.local/share/browse`, `~/.local/state/browse`, `~/.cache/browse`, and the user-level config files of the agents you choose. **Never modifies `/usr/share/omarchy/` or `/etc/`.**
- **Dual Interface**:
  - **MCP Mode**: After restarting already-running agents (Antigravity, OpenCode, Claude Code, Codex, Gemini CLI, VS Code, etc.), agents load the `browse` MCP server automatically.
  - **CLI Mode**: Available **immediately** after installation and pairing—no restart required—making it convenient for quick local verification (`browse navigate`, `browse snapshot`, `browse console`, `browse network`, `browse screenshot`).
- **Human Handoff & Boundaries**: Supports `handoff` (delegating sign-in, 2FA, CAPTCHA, or payment confirmation to the user), `--allowedOrigins` (restricting reachable origins), and `--readOnly` (read-only inspection).

Install this skill via the standard skills CLI:

```bash
npx skills add interjc/omarchy-skills --skill omarchy-browser-use
# Or install all skills: npx skills add interjc/omarchy-skills
```

## Confirm Preferences First

Before downloading binaries or editing agent configs, inspect the current state and confirm the user's preferences rather than overwriting all agent configs by default:

1. **Check Existing State**: Run `bash skills/omarchy-browser-use/scripts/setup.sh --status` (or `browse status`) to see whether the binary is installed, the relay is running, and Chrome is paired.
2. **Confirm Installation Source**: Download and run the official installer `https://opencode.ai/browse/install` (installs to `~/.local/bin/browse` with automatic updates on the `stable` channel; users who want manual control can run `browse update --mode notify` or `browse update --mode off` afterward).
3. **Confirm Target Agents**:
   - `all`: Register `browse` in every detected/supported agent (OpenCode, Antigravity, Claude Code, Codex, Gemini CLI, VS Code, etc.).
   - Explicit comma-separated list (e.g., `antigravity,codex,claude,opencode`): Update only the named agents.
   - `none` / `keep`: Do not modify agent MCP files; either print the MCP snippet or use CLI only.
4. **Confirm Immediate Browser Pairing**: Decide whether to generate a one-time pairing code and wait for the Chrome extension to connect now.

## Quick Start

Run from the repository root (if installed via `npx skills`, run `scripts/setup.sh` from the installed skill directory):

```bash
# 1. Read-only check of browse binary, relay, and pairing state (writes nothing)
bash skills/omarchy-browser-use/scripts/setup.sh --status

# 2. Interactive wizard (confirms each preference before applying)
bash skills/omarchy-browser-use/scripts/setup.sh

# 3. Non-interactive example: install browse, configure only Antigravity & Codex, and pair Chrome
bash skills/omarchy-browser-use/scripts/setup.sh \
  --install yes \
  --agents antigravity,codex \
  --pair yes \
  --wait-seconds 180

# 4. Generate a pairing code using an existing install without touching agent configs
bash skills/omarchy-browser-use/scripts/setup.sh \
  --install skip \
  --agents keep \
  --pair yes
```

### Script Options

| Flag | Values | Behavior |
| :--- | :--- | :--- |
| `--status` / `--check-only` | none | Read-only check of binary path, version, relay, and extension pairing |
| `--install` | `yes` \| `skip` | Download and install `~/.local/bin/browse` if missing (idempotent when already present) |
| `--agents` | `all` \| `none` \| `keep` \| comma list | Configure all agents, print MCP entry only, leave configs untouched, or target specific agents (e.g., `antigravity,claude`) |
| `--pair` | `yes` \| `skip` | Run `browse pair` to print a one-time pairing code and wait for Chrome |
| `--wait-seconds` | positive integer (default `180`) | Maximum wait time when `--pair yes` is set |
| `--help` / `-h` | none | Print usage without making changes |

## Manual Setup & Pairing

To configure everything step by step:

### 1. Install `browse` and Register Agents

```bash
curl -fsSL https://opencode.ai/browse/install | bash
```

- Installs the binary to `~/.local/bin/browse` and prompts you to select which agents should receive the MCP entry (for example, Antigravity writes to `~/.gemini/config/mcp_config.json`, OpenCode to `~/.config/opencode/opencode.json`, Claude Code to `~/.claude.json`, and Codex to `~/.codex/config.toml`).
- For non-interactive agent selection:
  ```bash
  ~/.local/bin/browse install -a antigravity -a codex --no-open --no-wait
  ```

### 2. Install the Chrome Extension

Install the `browse` extension from the Chrome Web Store in your Chrome-family browser:

- Extension URL: `https://chromewebstore.google.com/detail/mfnicocicmmlkpjnaffgihfjhdgjkdjg`

### 3. Pair Your Browser with the Local Relay

Once the extension is installed and Chrome is open, if the extension reports that the browser is not paired yet (`browse found the relay on this computer, but this browser isn't paired with it yet`), generate a one-time pairing code:

```bash
~/.local/bin/browse pair --wait-seconds 180
# Or rerun: ~/.local/bin/browse install -y
```

Then in Chrome:
1. Open **Extensions → browse → Options** (or click **Pair with a code** right inside the extension notice).
2. Enter the one-time pairing code printed in the terminal (e.g., `XXXX-XXXX`).
3. Click **Connect**.

### 4. Restart Running Agents (for MCP)

After pairing:
- Restart any already-running agent clients (or open a fresh session in T3 Code / your terminal) to load the `browse` MCP tools.
- In an already-open session before restarting, you can use the **CLI** (`~/.local/bin/browse ...`) immediately against your paired Chrome.

## Everyday Local Dev Workflows

### Open a Local Dev Page and Keep It Visible

> **Important**: By default, `browse navigate <url>` opens a **background tab** and closes idle tabs automatically. During interactive local development, pass `--keepVisible --keepOpen`:

```bash
# Open a local dev server or public URL, keeping the tab visible and open
browse navigate http://localhost:3000 --keepVisible --keepOpen --group local-dev
```

The command returns JSON containing the `tab` ID for subsequent commands (`--tab <id>`):

```json
{
  "url": "http://localhost:3000/",
  "navigated": true,
  "title": "My App",
  "status": 200,
  "tab": 1829832789
}
```

### Common Debugging Commands

```bash
# Inspect page outline and interactive element refs (e.g. e12)
browse snapshot --tab <id>

# Interact and wait for state
browse click e12 --tab <id>
browse fill e5 "hello" --tab <id>
browse press Enter --tab <id>
browse wait_for --text "Saved" --tab <id>

# Capture console logs, network traffic, screenshots, and visual diffs
browse console --tab <id>
browse network --tab <id>
browse screenshot --tab <id> --output /tmp/page.png
browse screenshot_diff --tab <id> ...

# Emulate mobile viewport / color scheme
browse emulate --tab <id> --json '{"viewport":{"width":390,"height":844,"mobile":true},"colorScheme":"dark"}'

# List or close managed tabs
browse tabs
browse tabs close --tab <id>
```

### Safety Boundaries & Agent Sandbox Notes

- **Origin & Read-Only Guardrails**: Pass `--allowedOrigins '["http://localhost:3000"]'` or `--readOnly` when opening tabs for scoped debugging or read-only checks.
- **Human Handoff**: When encountering sign-in, 2FA, CAPTCHA, or payment confirmation, call `browse handoff --tab <id>` so the user completes it directly; never attempt to bypass authentication or anti-bot checks.
- **Agent Terminal Sandbox Caveat**: The `browse` CLI reads `~/.config/browse` and talks to the loopback relay at `http://127.0.0.1:19988`. Inside a network-restricted sandbox, it fails with `browse: browse relay did not start at http://127.0.0.1:19988`. In that case:
  - Prefer calling the loaded `browse` MCP tools after restarting the agent; or
  - Run the `browse` CLI in an environment permitted to reach the local loopback relay.
- **Update Control**: Automatic `stable` updates are enabled by default; run `browse update --mode notify` or `browse update --mode off` if you prefer pinning versions.

## Verification & Rollback

### Live Verification

```bash
# Verify binary, relay endpoint, extension pairing, and configured agents
browse status

# List available tools
browse tools

# Smoke test: open a page in real Chrome and confirm status 200 + tab id
browse navigate https://www.google.com --keepVisible --keepOpen
```

### Offline Repository Checks

```bash
bash -n skills/omarchy-browser-use/scripts/setup.sh
bash -n skills/omarchy-browser-use/scripts/test.sh
bash skills/omarchy-browser-use/scripts/test.sh
```

### Unpairing & Uninstalling

```bash
# List paired browsers and revoke a specific one
browse pair --list
browse pair --revoke <browser-id-or-name>

# Full uninstall: remove MCP entries from agents, stop the relay, and delete ~/.local/bin/browse + user files
browse uninstall
```
