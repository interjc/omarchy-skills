---
name: omarchy-macbook-behavior
description: Configure confirmed MacBook-style trackpad and shortcut preferences on Omarchy's Lua Hyprland configuration, including three-finger drag and four-finger gestures. Audit live shortcuts and guide optional multilingual input, lid/power and hardware diagnostics without replacing personal configuration.
---

[English](SKILL.md) | [简体中文](SKILL_ZH.md)

# Omarchy MacBook Behavior

## Scope and Compatibility

The **2026-11-22** audit used Omarchy **`4.5.0-3`** and Hyprland **`0.56.2-4`**. Automation requires the Lua configuration with `require("default.hypr.omarchy")`. Integrate older `.conf` setups manually for their specific version. [Omarchy v4.5.0 release](https://github.com/omacom/omarchy/releases/tag/v4.5.0)

The installed 4.5 screenshot wrapper invokes Omasnap with notifications. The historical **`4.0.6-1`** wrapper used grim, `omarchy-capture-region` and tensaku, so that machine used its separately installed Omasnap. The 4.5 defaults do not read `omarchy_default_gestures`. Use `--keep-trackpad` for shortcut-only installation to keep using the existing `input.lua`.

Omarchy already provides clipboard history, screenshot capture, multilingual input switching, lid/clamshell handling, and Apple SMC lid bindings. This skill adds a small, optional trackpad/shortcut override, not a replacement desktop stack or guaranteed macOS behavior. It never changes `/usr/share/omarchy/`.

Install/discover with the standard skills CLI:

```bash
npx skills add interjc/omarchy-skills --skill omarchy-macbook-behavior
```

## Confirmation First

Before applying any change, inspect the actual configuration and ask for the user's choices. Do not silently choose scrolling, shortcuts, languages, tap behavior, idle timeouts or lid policy.

1. Run the read-only auditor: `bash skills/omarchy-macbook-behavior/scripts/recommend-shortcuts.sh`. It prints live `hyprctl binds -j`, then a clearly labeled snapshot table. Review custom bindings and gesture definitions too; a source excerpt alone is not an effective-binding audit.
2. Choose **natural**, **traditional**, or **keep trackpad**. Natural scrolling moves content with the fingers; traditional reverses that direction. Selecting either direction opts into three-finger drag, disable-while-typing, and the replacement gesture scheme described below. Existing acceleration, tap/click choices and terminal scroll factors remain unchanged.
3. Choose screenshot **keep**, **Super+Ctrl+A**, **Alt+Shift+4**, or **both**. Super+Ctrl+A replaces Audio by default; any chosen chord can replace a personal binding. Alt+Shift+4 is an alternative chord, not the physical equivalent of macOS Cmd+Shift+4.
4. Choose clipboard **keep** or add **Super+Shift+Z**. This is an optional alias, not a universal Alfred default; check personal conflicts. The native Super+Ctrl+V binding is not removed.
5. Choose text deletion **keep**, `macos-alt` (recommended), or `macos-ctrl-w`: maps `Option+Delete` (`ALT + BACKSPACE`, with key repeat) to word delete (GUI: `CTRL + BackSpace`; terminals: `ALT + BackSpace` or `CTRL + W`), maps `Super+Delete` (`SUPER + BACKSPACE`) to delete-to-line-start (GUI: `SHIFT + Home` → `BackSpace`; terminals: `CTRL + U`), and relocates stock `SUPER + BACKSPACE` (Toggle transparency on a window) to `SUPER + ALT + BACKSPACE`.
6. Choose cursor navigation **keep**, `option-only`, or `macos-full`: `option-only` enables conflict-free `Option+Left/Right` (+ `Shift`) word navigation/selection; `macos-full` also maps `Super+Arrows` (+ `Shift`) to line/document navigation and selection, relocating stock Hyprland window focus/swap to `CTRL + ALT + Arrows` / `CTRL + ALT + SHIFT + Arrows`.
7. Discuss language and power changes separately if requested. Setup does not install packages or alter Fcitx, Rime, system services, udev, logind or shell timers.

## Quick Start

Run from the repository root, adjusting the path if installed elsewhere:

```bash
# Read-only, even on a TTY:
bash skills/omarchy-macbook-behavior/scripts/recommend-shortcuts.sh

# Interactive: every missing preference requires a choice, then confirmation.
bash skills/omarchy-macbook-behavior/scripts/setup.sh

# Explicit automation: trackpad, screenshot, and clipboard are mandatory;
# --text-deletion and --cursor-navigation are optional (default to keep when omitted noninteractively).
bash skills/omarchy-macbook-behavior/scripts/setup.sh \
  --natural-scroll --screenshot-hotkey alt-shift-4 --clipboard-hotkey super-shift-z \
  --text-deletion macos-alt --cursor-navigation macos-full

# Keep trackpad and screenshot behavior; add only a clipboard alias:
bash skills/omarchy-macbook-behavior/scripts/setup.sh \
  --keep-trackpad --screenshot-hotkey keep --clipboard-hotkey super-shift-z

# Shortcut-only on the legacy release; preserve personal input.lua:
bash skills/omarchy-macbook-behavior/scripts/setup.sh \
  --keep-trackpad --screenshot-hotkey super-ctrl-a --clipboard-hotkey super-shift-z
```

Trackpad flags: `--natural-scroll`, `--traditional-scroll`, `--keep-trackpad`. Screenshot values: `keep`, `super-ctrl-a`, `alt-shift-4`, `both`. Clipboard values: `keep`, `super-shift-z`. Text deletion values (`--text-deletion`): `keep`, `macos-alt`, `macos-ctrl-w`. Cursor navigation values (`--cursor-navigation`): `keep`, `option-only`, `macos-full`. Both text-editing options default to `keep` when omitted noninteractively and are prompted in interactive TTY sessions. Unknown arguments, missing values, invalid choices and incomplete noninteractive invocations fail before writes. Explicit complete flags constitute consent; an agent must still obtain the user's preferences first.

### Screenshot Command Detection

When a screenshot shortcut is requested, setup resolves the actual executable wrapper on `PATH` with `type -P omarchy-capture-screenshot` and reads that file without running screenshot commands to probe capabilities. `${OMARCHY_PATH:-/usr/share/omarchy}` is installation context only; its same-named source may differ from the command on `PATH` and is not authoritative for detection:

- If it finds a line-leading `omasnap ...` or `exec omasnap ...` command invocation in the resolved executable, it selects `omarchy-capture-screenshot`. Comments, names inside arguments and the `omasnap_args` variable do not count as invocations.
- For an actual wrapper using legacy grim/tensaku, an unrecognized or unreadable wrapper, or no executable wrapper on `PATH`, it selects the installed bare command `omasnap` on `PATH`, without `--notify`, `--save` or other arguments. It does not fall back to the old screenshot workflow.
- Both paths require an executable `omasnap` on `PATH`. Missing required commands cause an error before any writes, never a silently omitted screenshot binding. Screenshot `keep` needs neither tool.

Setup prints exactly `Screenshot command: omarchy-capture-screenshot` or `Screenshot command: omasnap`. The newer wrapper supplies notification and screenshot-directory compatibility; the direct path uses the installed omasnap's own preview, saving and directory behavior, which is not guaranteed to match the newer wrapper.

### Managed Integration

Setup preserves `input.lua`, `bindings.lua` and other personal modules. It backs up changed files using unique `.macbook-backup.*` filenames, then manages only `macbook_behavior.lua` and two marked blocks in `~/.config/hypr/hyprland.lua`:

```lua
-- BEGIN omarchy-macbook-behavior gestures
omarchy_default_gestures = false
-- END omarchy-macbook-behavior gestures
require("default.hypr.omarchy")
-- ... existing personal modules and other configuration remain unchanged ...
-- BEGIN omarchy-macbook-behavior overrides
require("hypr.macbook_behavior")
-- END omarchy-macbook-behavior overrides
```

Setup installs the early block only when trackpad changes are selected and the installed defaults read that flag. Rerunning after an upgrade removes the old block if the defaults no longer read it. The override loads after personal configuration. Reruns with the same options and installed defaults make no further writes or backups. **`keep` removes that category's skill-managed override, and any equivalent personal shortcut or gesture can still take effect.** Setup refuses symlinked targets and existing overrides without their ownership header. Keep that header and put manual customizations in separate personal files.

The script does not explicitly reload Hyprland, but Hyprland may auto-reload on writes. Review and test immediately in the session:

```bash
hyprctl reload
hyprctl configerrors
hyprctl binds -j
```

### Existing Installations

Earlier versions of this skill overwrote `input.lua`, appended direct `omasnap`/F12 bindings, wrote Fcitx/Rime files, and optionally installed system overrides. **The new setup does not undo those changes automatically.** Back up and review them first; restore your own pre-skill backups where appropriate, not somebody else's defaults.

- Remove old gesture registrations from personal files before enabling the new scheme. Setup rejects obvious `hl.gesture` definitions in `input.lua`, but cannot discover every indirect module, alias or dynamically created gesture; inspect the full load graph.
- Remove legacy `no_screen_share` rules matching `omasnap`, including those in other modules. They break scrolling capture. The installer flags the common legacy case in `bindings.lua`, not every possible rule.
- Review old screenshot bindings and select the command by capability as above: `omarchy-capture-screenshot` for the newer wrapper, or `omasnap` for a legacy wrapper with the standalone tool installed. Do not force the grim/tensaku workflow on older machines. Remove old F12 mappings only if the user wants that; F12 is not a current upstream screenshot default.
- If a screenshot or clipboard shortcut appears in both personal configuration and the managed module, check the effective binding with `hyprctl binds -j`. Keep the user's chosen chord, consolidate the binding in one file after confirmation, and use the official 4.5 wrapper to retain screenshot notifications.
- Preserve/restore Fcitx profiles, language engines, Rime customizations and personal dictionaries. Group-cycling bindings in a one-group profile never cycled its engines correctly. Review old Super+Space/Control+Space IME overrides against the native behavior below.
- Review any old `/etc` drop-ins or udev rules manually; this installer neither installs nor deletes them.

## Manual Trackpad and Shortcuts

Back up `hyprland.lua` and any file to be edited. When enabling the replacement trackpad scheme, look for an `omarchy_default_gestures` condition around the default gestures in the installed `default/hypr/omarchy.lua`. Only when that condition exists, set the flag to `false` **before** the defaults import. Load a separate override at the end of `hyprland.lua` and choose settings and a `natural_scroll` value from [hyprland-input.lua](references/hyprland-input.lua).

The historical `quattro` snapshot registered default three- and four-finger gestures. The flag controls that upstream module. For selective manual changes, use a call such as `hl.gesture({ fingers = 3, direction = "up", action = "unset" })` to unset each conflicting direction before defining the new gesture.

The supplied replacement scheme is:

| Gesture | Action |
| --- | --- |
| Three-finger movement | Left-button drag via `drag_3fg = 1` |
| Four-finger horizontal swipe | Switch workspace |
| Four-finger up/down | Toggle the `scratchpad` special workspace |
| Four-finger pinch-in | Open Omarchy menu |

Scratchpad is a special workspace, not macOS Mission Control. Hardware support and drag feel require real-device testing. `disable_while_typing = true` requests libinput behavior; it cannot guarantee palm rejection on every device. Keep upstream acceleration and scroll factors unless the user separately requests tuning; optional tap/click, speed and wake settings can be customized in personal input configuration after confirmation.

For shortcut-only manual changes, choose examples from [hyprland-bindings.lua](references/hyprland-bindings.lua), unbind the selected chord, then bind through `o.bind`. Select **`omarchy-capture-screenshot` or bare `omasnap`** using the detection above; do not assume a same-named wrapper invokes the same tool on every release. Leave native Print/Super+Ctrl+Alt+C alone unless explicitly asked. No extra overlay rule is needed; never add `no_screen_share` for `omasnap`.

### Optional: macOS-Style Text Deletion (`Option + Delete` / `Super + Delete`)

See [hyprland-text-deletion.lua](references/hyprland-text-deletion.lua) (or pass `--text-deletion macos-alt` / `macos-ctrl-w` to `setup.sh`). It reuses Omarchy 4.5's `hl.dsp.send_key_state` and `terminal` window-tag pattern from `default/hypr/bindings/clipboard.lua` without installing `keyd` or any system service:

| Shortcut | Hyprland Binding | GUI Apps | Terminal Windows | Conflict Handling |
| --- | --- | --- | --- | --- |
| `Option + Delete` | `ALT + BACKSPACE` (`repeating = true`) | `CTRL + BackSpace` | `ALT + BackSpace` (`macos-alt`, punctuation-aware) or `CTRL + W` (`macos-ctrl-w`) | None |
| `Super + Delete` | `SUPER + BACKSPACE` | `SHIFT + Home` → `BackSpace` | `CTRL + U` | Relocates stock "Toggle transparency on a window" to `SUPER + ALT + BACKSPACE` |

Known edge cases: in GUI apps, pressing `Super + Delete` when the cursor is already at column 0 sends an empty selection + `BackSpace`, merging the line with the previous line (`Ctrl + U` in terminals does not); code editors with smart `Home` delete to the indentation start on the first press; behavior during uncommitted IME preedit depends on the app's input widget.

### Optional: macOS-Style Cursor Navigation & Selection (`Option / Super + Arrows`)

See [hyprland-cursor-navigation.lua](references/hyprland-cursor-navigation.lua) (or pass `--cursor-navigation option-only` / `macos-full` to `setup.sh`), reusing the same `send_key_state` + terminal-tag pattern:

| Shortcut | Mode | GUI Apps | Terminal Windows | Conflict Handling |
| --- | --- | --- | --- | --- |
| `Option + Left/Right` (+ `Shift`) | `option-only` / `macos-full` | `CTRL (+ SHIFT) + Left/Right` | `ALT (+ SHIFT) + Left/Right` | No WM conflict (replaces browser `Alt+Left/Right` history navigation with word navigation) |
| `Super + Left/Right` | `macos-full` | `Home / End` | `CTRL + A / CTRL + E` | Relocates stock Hyprland window focus to `CTRL + ALT + Arrows` |
| `Super + Shift + Left/Right` | `macos-full` | `SHIFT + Home / End` | `SHIFT + Home / End` | Relocates stock Hyprland window swap to `CTRL + ALT + SHIFT + Arrows` |
| `Super + Up/Down` (+ `Shift`) | `macos-full` | `CTRL (+ SHIFT) + Home / End` | `CTRL (+ SHIFT) + Home / End` | Same as above; leaves `Option + Up/Down` untouched for editor line-move shortcuts |

## Optional Input Methods

Current Omarchy runs Fcitx under the **session user unit** `omarchy-fcitx5.service`. Inspect before changing anything:

```bash
omarchy-input-method status
systemctl --user status omarchy-fcitx5.service
fcitx5-remote -q   # Current group
fcitx5-remote -n   # Current engine
```

Omarchy's `installed_method` reflects the preset it recognizes. A configured Rime engine can run while this field reports `none`. Check Fcitx's current group and engine for its active state.

Native **Super+I / Super+Shift+I** cycle input languages through Omarchy's shell. **Super+Space** opens the menu. **Ctrl+Space** is a non-consuming terminal-prefix helper that requests direct input in terminals; do not replace it with a consuming launcher/IME binding by default. Cmd+Space is commonly Spotlight on macOS, not a universal input-source toggle. Fcitx custom hotkeys may still exist on upgraded installs; inspect them instead of forcing new ones.

If personal configuration also uses `Ctrl+Space` for the menu, `hyprctl binds -j` can list both the menu and the terminal helper after an upgrade. Confirm the user's intended behavior before adjusting either binding.

### Switch with Super+I only

Use these overrides only when the user chooses a single switching key. Users who want reverse cycling or dedicated Fcitx keys can keep those bindings.

1. To restore the stock menu and terminal helper, remove the personal Lua lines that unbind `SUPER + SPACE` and bind the menu to `CTRL + SPACE`. Add `hl.unbind("SUPER + SHIFT + I")` to personal bindings and keep native forward cycling.
2. Back up the Fcitx `config`. Clear switching lists using the [Fcitx example](references/fcitx5-config). Preserve candidate and preedit keys, installed engines, and dictionaries. Set explicit empty values under `[Hotkey]` and remove the corresponding old list sections. Deleting the settings alone can restore Fcitx's default switching keys.
3. Reload settings with `fcitx5-remote --check -r`, then run `hyprctl reload`, `hyprctl configerrors`, and `hyprctl binds -j`. Verify the menu, the terminal prefix, and cycling among existing engines with `Super+I`. Use `fcitx5-remote -n` to compare the engine before and after cycling. Omarchy's native shortcut cycles engines within the current group.

### Install and preserve input engines

Use `omarchy setup input` (or `omarchy-setup-input`) for the current native interactive configurator. Confirm languages and inspect the proposed package/configuration changes. Prefer its supported presets, including Japanese Mozc where available, over a replacement profile. Do not use reset/defaults options merely to add a language.

For **Rime**, which may not be offered by the native preset picker:

1. Confirm Chinese input and install only the needed package, e.g. `sudo pacman -S --needed fcitx5-rime`. Install an available configuration editor separately only if needed and confirmed.
2. Back up the existing Fcitx profile/config. Use an available Fcitx input-method editor to **add Rime to the existing group**, preserving the current keyboard, other engines, order and custom hotkeys. Do not copy [fcitx5-profile](references/fcitx5-profile) or [fcitx5-config](references/fcitx5-config) over live files; these are guidance/examples only.
3. For optional Rime-Ice, review its current upstream installation instructions, back up the Rime data directory (`${XDG_DATA_HOME:-~/.local/share}/fcitx5/rime`), and merge schemas/patches selectively. Do not clone over a live dictionary tree or replace existing `default.custom.yaml`. [rime-default.custom.yaml](references/rime-default.custom.yaml) is only an optional merge example after the schema is installed.
4. Apply changes through the editor/redeploy Rime. If a restart is needed, use `systemctl --user restart omarchy-fcitx5.service`, not a second `fcitx5 -r -d` daemon. Test native cycling and terminal Ctrl+Space afterward. Do not promise native integration for manually added engines until tested on the installed version.

Per-window input state, candidate paging and single-Shift toggling are separate user preferences, not prerequisites. Never overwrite the entire Fcitx configuration to set them. Cycling Fcitx **groups** with just one group does not cycle US/Rime/Mozc **engines** within it.

## Optional Power Review

No power changes are automated. Current upstream already ships `InhibitDelayMaxSec=15`; [logind-inhibit-delay.conf](references/logind-inhibit-delay.conf) is a snapshot reference, **not a drop-in to install**. This is a maximum inhibitor delay, not a guarantee that a lock screen rendered before suspend.

Native lid bindings handle both `Lid Switch` and `Apple SMC power/lid events`, calling `omarchy-system-lid-close` and `omarchy-hyprland-monitor-clamshell`. Do not duplicate those bindings or Apple hooks. Battery/AC, external displays, dock state, inhibitors, firmware and wake devices can change observed behavior. Inspect the installed commands and logs instead of claiming sleep/clamshell was optimized.

For idle timers, preserve the **complete canonical** `~/.config/omarchy/shell.json`. Current format requires **`"version": 1`**, and is not a deep-merge overlay; a tiny `{"idle": ...}` file can discard/reset unrelated bar, dock and plugin settings. The upstream defaults are already **screensaver 150 seconds / lock 300 seconds**. Only edit the requested fields in the existing full file after confirming durations. If missing, review the full installed template at `/usr/share/omarchy/config/omarchy/shell.json` first. Do not replace a customized file with the template.

Useful read-only checks:

```bash
systemd-analyze cat-config systemd/logind.conf
systemd-inhibit --list
hyprctl binds -j
journalctl -b -u systemd-logind --no-pager
```

Save work and explicitly obtain permission before testing actual suspend, lid-close or dock changes. Check lock behavior after wake on battery and with the intended external-display setup; do not infer security from the timeout alone.

## Hardware Diagnostics

Never install a udev override just because `bcm5974`/`applespi` is loaded. First identify the touchpad's actual event node with `libinput list-devices`, then inspect `udevadm info --query=property --name=/dev/input/eventN` and its hardware identity. These read-only diagnostics may require privilege on the installed system. Determine whether the device is genuinely internal, incorrectly classified external, and lacks expected disable-while-typing behavior.

Only after that diagnosis and explicit opt-in, consider the [udev example](references/71-apple-trackpad-internal.rules). Narrow it with a verified device-specific parent match; the broad driver match alone is not safe for every machine and is not an Apple Silicon recipe. Back up any existing rule, install the reviewed scoped rule under `/etc/udev/rules.d/`, and apply it during an agreed maintenance/reboot window. Validate the properties and typing behavior again. Hardware classification is not a guaranteed palm-rejection fix.

## Verification and Rollback

- Run `hyprctl reload` and `hyprctl configerrors`; inspect errors, not just reload exit status.
- Test three-finger text selection and window drag, all selected four-finger gestures, scroll direction and disable-while-typing on actual hardware.
- Check the reported screenshot command and test selected shortcuts, annotation, notifications/preview supported by the selected path, and **scrolling capture**. The direct path does not promise newer-wrapper notification behavior. Ensure no inherited `omasnap` `no_screen_share` rule remains.
- Test clipboard alias and existing native shortcuts; review `hyprctl binds -j` for conflicts.
- For optional IME changes, test each engine, the selected cycling directions, GUI/terminal composition, and terminal-prefix passthrough. Check the existing user service.
- Repository checks: run `bash -n` on each script, then `bash skills/omarchy-macbook-behavior/scripts/test-setup.sh`. The sandbox tests use a temporary HOME, isolated `OMARCHY_PATH` and whitelisted utilities/mocked commands, covering newer wrappers, legacy direct invocation, version mismatches between `OMARCHY_PATH` and `PATH` in both directions, missing-tool/no-write failures and shortcut-only installation preserving the trackpad; they do not prove live Hyprland/hardware behavior.

To disable this installer's choices, rerun with `--keep-trackpad --screenshot-hotkey keep --clipboard-hotkey keep`. To remove the integration completely, back up current files, remove only both marked blocks in `hyprland.lua`, then remove the managed `macbook_behavior.lua`. Restore a `.macbook-backup.*` file only after comparing it with current content so later personal edits are not lost. Reload and inspect configuration errors afterward. Legacy changes outside the managed blocks require separate manual rollback.
