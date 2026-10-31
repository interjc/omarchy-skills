---
name: omarchy-agent-agy
description: Integrate Antigravity CLI (agy) with Omarchy, preferring native default-agent support and using an approved Gemini shim only on detected legacy installations. Includes an optional experimental background session and manual usage-bar configuration.
---

[English](SKILL.md) | [简体中文](SKILL_ZH.md)

# Omarchy Agent: Antigravity CLI

## Audit Evidence And Architecture

Audited on **2026-10-31** against Omarchy's default branch `quattro`, commit
`bda3aaf6955404712dbd46541e6c8a75a2b16b7c`, and the latest fetched stable tag, `v4.0.6`.
These snapshots differ: default-branch functionality must not be presented as already shipped in stable.

| Check | quattro commit | v4.0.6 |
| --- | --- | --- |
| `omarchy-agent` dispatch | Native `agy` with `--dangerously-skip-permissions` | `gemini --yolo`; no `agy` branch |
| `omarchy-default-agent` | Accepts `agy`; normalizes aliases including `gemini` to `agy` | Accepts and saves `gemini`; rejects `agy` |
| Default menu entry ID | `setup.default.agent.agy` | `setup.default.agent.gemini` |
| Stock shortcut | `SUPER + SHIFT + CTRL + A` → `omarchy-agent --pick` | Same |

Prefer native `omarchy-default-agent agy`. Never write `gemini` directly into the default file on
the native implementation: its dispatcher no longer supports that ID. Only after detecting both
legacy scripts and obtaining explicit approval should setup install `~/.local/bin/gemini` and save
the legacy default ID `gemini`. The wrapper translates `--yolo` to
`--dangerously-skip-permissions`, interactive prompts to `-i`, and one-shot prompts to `-p`.
Other arguments retain their order; parsing stops at `--`.

System scripts are read-only. Never modify `/usr/share/omarchy/`. Detection examines actual branches
under `${OMARCHY_PATH:-/usr/share/omarchy}/bin/`, not guessed version numbers; unknown implementations fail closed.

## Confirm Preferences First

Before applying configuration, confirm whether to change the default agent and whether to enable
the optional service. Both native Omarchy dispatch and the legacy shim bypass agent permission
prompts; disclose this rather than presenting it as an ordinary launch.
Keep existing shortcuts, menus, and other providers unless the user requests changes.

The background stream-json session is **experimental and optional**. It adds no permission-bypass
flags and does not guarantee a quota endpoint, continuous availability, zero CPU, or a fixed memory
footprint. Check the installed `agy --help` and authentication before approving it.
It starts with the user session; setup does not enable lingering.

## Quick Start

Install using the standard skills CLI:

```bash
npx skills add interjc/omarchy-skills --skill omarchy-agent-agy
# Or install the collection: npx skills add interjc/omarchy-skills
```

Install and authenticate `agy` separately; check `agy --version` and `agy --help`. From the repository root:

```bash
# In a terminal, ask for missing preferences before writing anything.
bash skills/omarchy-agent-agy/scripts/setup.sh

# Noninteractive use requires both choices explicitly.
bash skills/omarchy-agent-agy/scripts/setup.sh --default-agent agy --daemon keep

# Legacy only; this flag never forces a native installation onto the shim path.
bash skills/omarchy-agent-agy/scripts/setup.sh --default-agent agy --daemon keep --legacy-shim

# Independently approve the experimental service; the executable need not be in /usr/bin.
bash skills/omarchy-agent-agy/scripts/setup.sh --default-agent keep --daemon enable --agy-bin /absolute/path/to/agy
```

After a skills CLI installation, run `scripts/setup.sh` from the actual installed skill directory
instead of assuming the repository-relative path above exists.

| Flag | Behavior |
| --- | --- |
| `--default-agent agy\|keep` | Select native or approved legacy mapping, or keep the current default |
| `--daemon enable\|keep` | Create and enable the service, or leave existing service state unchanged; `keep` does not disable it |
| `--legacy-shim` | Allow the Gemini shim only on detected legacy Omarchy; shadows all `gemini` calls on PATH |
| `--replace-existing` | Explicitly replace conflicting shim, service, or runner files after backup; does not merge custom code |
| `--agy-bin /absolute/path` | Service executable; defaults to resolving `agy` on PATH to its absolute real path |
| `--help` / `-h` | Show help without configuration changes |

Setup covers only the default-agent mapping and approved service. It does not install packages or
plugins, or edit menus, shortcuts, TOML, or `shell.json`. The native setter itself may install a
tool through mise and launch a terminal; setup does not hide that behavior.
If the setter returns before saving `agy`, setup reports an error asking to finish installation and
rerun rather than prematurely claiming success.
It skips the setter when the desired default is already selected and does not rewrite identical generated files.
Replacements print a backup path, `<file>.backup.XXXXXX/original`. Symlinked default files are not modified automatically.
Missing options, unknown capabilities, and file conflicts fail before writes; external setter or
systemd failures propagate as errors, not as a transaction rollback across all operations.
Even `--replace-existing` never overwrites menus or layouts.

## Manual Setup And Options

### Default Agent And Menu

Read the installed `bin/omarchy-agent` and `bin/omarchy-default-agent` and compare with the evidence table.
For native support use `omarchy-default-agent agy`, with no menu override.
For the verified legacy implementation, review and install `references/gemini-wrapper.sh` as executable
`~/.local/bin/gemini`, and only there set `~/.config/omarchy/defaults/agent` to `gemini`.
Back up any replacement first; review a conflicting shim instead of blindly copying over it.

The legacy wrapper requires `~/.local/bin` before other `gemini` executables on PATH.
Inspect `type -a gemini` and `command -v agy`, including the desktop session's PATH; editing a shell
RC does not necessarily update an already running desktop. Do not uninstall the real Gemini CLI
merely to force PATH precedence.

Only if the user wants the legacy menu renamed, back up and read the complete
`~/.config/omarchy/extensions/omarchy-menu.jsonc`, then manually merge the member from
[`references/omarchy-menu.jsonc`](references/omarchy-menu.jsonc) into its existing JSONC object,
preserving comments and other entries. Never overwrite a customized file with the example or claim
setup merged it. Menus hot-reload. After upgrading to native support, detect again and use the native
setter; review whether anything else depends on the old menu override or shim before archiving them.
Do not automatically delete user files.

### Shortcut

Preserve stock `omarchy-agent --pick`: it opens the selection menu when unset, otherwise launches
through default dispatch. If the user explicitly requests another key, inspect conflicts, back up,
and edit existing `~/.config/hypr/bindings.lua`, using
[`references/hyprland-bindings.lua`](references/hyprland-bindings.lua). Keep calling the dispatcher,
not direct `agy`. Run `hyprctl reload` and `hyprctl configerrors` afterward.

### Experimental Background Service

[`references/agy-daemon.service`](references/agy-daemon.service) is a template, not a ready-to-install
unit. Setup replaces `@AGY_BIN@` with the resolved, escaped absolute executable path and installs
[`references/agy-daemon.sh`](references/agy-daemon.sh) under `~/.local/lib/omarchy-agent-agy/`.
The runner holds stdin open without sending requests; that alone does not establish that a Language
Server RPC or quota endpoint is available. If PATH resolves to a launcher such as a mise shim,
use `--agy-bin` to select the actual installed binary. If upgrades change that path, review backups
and rerun the explicit service-enablement flow.

Enablement uses `systemctl --user daemon-reload` and `enable --now`; changed service files trigger
a restart. To undo enablement manually: `systemctl --user disable --now agy-daemon.service`.

### Usage Bar, Separately Approved

Third-party plugins execute unsandboxed code inside the shell. Review the code and obtain approval
for installation and layout changes before running:

```bash
omarchy pkg aur add ai-usagebar-bin
omarchy plugin add https://github.com/akitaonrails/ai-usagebar.git --enable
```

Back up and edit `~/.config/ai-usagebar/config.toml` in place, using
[`references/ai-usagebar.toml`](references/ai-usagebar.toml). If `[antigravity]` exists, adjust
`enabled = true` there instead of duplicating the table or replacing other providers.
Do not change primary/UI preferences by default. Verify third-party fields and commands against
the installed version's help and documentation.

Read and back up the **complete** `~/.config/omarchy/shell.json`. Omarchy requires top-level
`"version": 1`; the user file is a complete configuration, not a deep merge with system defaults.
Preserve all fields and layout entries, adding `{"id": "akitaonrails.ai-usagebar"}` only to the
user-selected section array and only if absent. Never replace the file with a partial example.
If no user file exists, copy the installed complete default configuration before editing.
Layout changes hot-reload on save. If necessary:

```bash
omarchy-shell shell reloadConfig
# Or restart the full shell: omarchy restart shell
```

## Verification And Maintenance

```bash
omarchy-default-agent               # agy natively; gemini for approved legacy mapping
command -v agy
type -a gemini                     # Legacy only: check shim precedence
# These launch a permission-bypassing agent; run only after approval:
omarchy agent --inline
omarchy agent prompt "Hello Antigravity"
# Only if the service was selected:
systemctl --user is-active agy-daemon.service
systemctl --user status agy-daemon.service
journalctl --user -u agy-daemon.service -n 50 --no-pager
ai-usagebar --help
ai-usagebar --vendor antigravity    # Confirm support in installed help first
```

Check the shortcut and menu separately. Inspect actual quota output or errors rather than assuming
quota periods, values, or an RPC method. If offline, compare with authenticated `agy` running in a
visible terminal, then inspect service logs and installed CLI support. An active service is not
proof of a successful quota query.

Maintain packages with `omarchy update` or an available AUR helper; there is no `omarchy pkg aur update`.
Use `omarchy plugin update akitaonrails.ai-usagebar`, preserving local changes before updates;
run `omarchy-shell shell rescanPlugins` if needed. Recheck capabilities, CLI flags, and quota queries after upgrades.

Offline repository checks (no real installation):

```bash
bash -n skills/omarchy-agent-agy/scripts/setup.sh
bash -n skills/omarchy-agent-agy/references/gemini-wrapper.sh
bash -n skills/omarchy-agent-agy/references/agy-daemon.sh
bash skills/omarchy-agent-agy/scripts/test.sh
# Optional: also test both pinned snapshots from an existing read-only checkout.
bash skills/omarchy-agent-agy/scripts/test.sh /tmp/opencode/omarchy-latest
```

Tests use a temporary HOME and mocked Omarchy/systemctl. They do not verify real authentication,
desktop rendering, background resource consumption, or third-party quota endpoints.

## Upstream References

- [quattro dispatcher (pinned commit)](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/bin/omarchy-agent)
- [quattro default setter (pinned commit)](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/bin/omarchy-default-agent)
- [v4.0.6 dispatcher](https://github.com/basecamp/omarchy/blob/v4.0.6/bin/omarchy-agent)
- [v4.0.6 default setter](https://github.com/basecamp/omarchy/blob/v4.0.6/bin/omarchy-default-agent)
- [Native menu ID](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/default/omarchy/omarchy-menu.jsonc), [stock shortcut](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/default/hypr/bindings/utilities.lua)
- [Complete shell configuration](https://github.com/basecamp/omarchy/blob/bda3aaf6955404712dbd46541e6c8a75a2b16b7c/config/omarchy/shell.json), [ai-usagebar documentation](https://github.com/akitaonrails/ai-usagebar)
