[English](VALIDATION.md) | [简体中文](VALIDATION_ZH.md)

# Compatibility and Live-System Validation

## Audit Baseline

Validation date: **2026-10-31**. Comparisons were made against Omarchy's latest stable tag
[`v4.0.6`](https://github.com/omacom/omarchy/releases/tag/v4.0.6) and the pinned commit of the default branch
`quattro`,
[`bda3aaf6955404712dbd46541e6c8a75a2b16b7c`](https://github.com/omacom/omarchy/tree/bda3aaf6955404712dbd46541e6c8a75a2b16b7c).
Agent, screenshot, or input method capabilities cannot be inferred from the release version alone; the installers inspect the actual implementation and reject unknown Agent dispatch paths.

| Component | Live-System Environment for This Validation |
| --- | --- |
| Omarchy package | `4.0.6-1` |
| Hyprland | `0.56.2`, Lua configuration |
| Antigravity CLI | `1.4.10` |
| ai-usagebar | `1.47.0` |
| Omasnap | `1.17.0`, user-installed |
| Fcitx5 | `5.1.23`, managed by a user systemd service |

## Confirmed Differences

- The live system still dispatches through `gemini`; native `agy` support is a capability of the audited `quattro` snapshot. The live system therefore retains the user-approved Gemini shim rather than setting an `agy` default that cannot be dispatched.
- The live system's official screenshot wrapper still uses the grim/region-selection workflow, not Omasnap. The installer inspects the wrapper actually resolved through PATH and selects it only if it is confirmed to invoke Omasnap; otherwise, it uses the installed `omasnap` without switching screenshot tools without approval.
- The live system does not have the new default gesture module. Existing three-finger dragging and four-finger gestures remain unchanged; handling of conflicts with the new default gestures was validated against pinned upstream source and in a sandbox, not through live testing of the new gestures on this machine.
- The `no_screen_share` layer rule for Omasnap breaks the new scrolling screenshot feature and should be removed rather than continuing to be installed as a security improvement.
- `shell.json` must retain its complete configuration and top-level `version: 1`. Input method, power, and hardware settings are no longer unconditionally overwritten by "one-click installation."

## Live-System Execution

The user explicitly chose to "preserve existing habits and fix issues." The system was not upgraded, no plugins were installed, system directories were not modified, and suspend was not tested.
Traditional scrolling, three-finger dragging, existing four-finger gestures, Print/F12/Super+Ctrl+A screenshots,
Super+Shift+Z clipboard, Super+Space input method, and Ctrl+Space launcher were preserved.

The following approved installation commands were executed, each then repeated to check idempotency:

```bash
bash skills/omarchy-agent-agy/scripts/setup.sh \
  --default-agent agy --daemon enable --legacy-shim --replace-existing --agy-bin /usr/bin/agy
bash skills/omarchy-macbook-behavior/scripts/setup.sh \
  --keep-trackpad --screenshot-hotkey super-ctrl-a --clipboard-hotkey super-shift-z
```

In addition, `no_screen_share` was manually removed from the old screenshot rules, and the ineffective forward group-switching key in Fcitx that conflicted with the Ctrl+Space
launcher was cleared. The configuration was then reloaded with `fcitx5-remote -r`, without starting a second input method process.
This manual migration is not part of the installers' automatic cleanup behavior.

| Check | Actual Result |
| --- | --- |
| Hyprland reload | `hyprctl reload` succeeded; `hyprctl configerrors` was empty |
| Existing preferences | Traditional scrolling `false`, three-finger dragging `1`, disable touchpad while typing `true`; the original `input.lua` and Fcitx `profile` were byte-for-byte identical to their backups |
| Loaded bindings | One target binding each for Super+Ctrl+A, Print, F12, Super+Shift+Z, and Ctrl+Space |
| Wrapper | `gemini --version` returned the actual `agy` version `1.4.10`; the default ID remained `gemini` |
| Actual dispatch | `omarchy-agent --inline` was launched through a PTY in a temporary directory; Antigravity startup information appeared without unsupported Agent or argument errors; it was deliberately terminated by a timeout after 8 seconds, without submitting a prompt or performing a coding task |
| Background service | The new service was `active/running`, logs contained a new `event: init`, and the restart count was `0` when checked; the unit passed `systemd-analyze --user verify` |
| Quota | Running `ai-usagebar --vendor antigravity` with a separate cache directory returned quota and reset times without offline errors; the check went beyond whether the service was active |
| Screenshot output | `omasnap --capture-fullscreen --save` succeeded and produced a valid `2560 x 1600` PNG; image statistics showed it was not an all-black or constant image |
| Input method | Fcitx responded normally after reloading the configuration, with current group `Default` and engine `rime`; personal engine lists and dictionaries were not modified |
| Repeated installation | Running again with the same arguments caused no configuration rewrites or additional backups |

Screenshots were saved only locally in `/tmp/opencode/omarchy-live-validation/`, not uploaded or included in the repository.
Background memory and CPU figures were observations from a particular run, not a basis for promises of zero usage or fixed resource consumption.

## Automated Validation

```bash
bash skills/omarchy-agent-agy/scripts/test.sh /tmp/opencode/omarchy-latest
bash skills/omarchy-macbook-behavior/scripts/test-setup.sh
git diff --check
```

All passed. The first command's extra argument is a local read-only upstream checkout and may be omitted; when provided, the tests use the real
Agent scripts from two pinned snapshots with mock executables, without triggering an actual installation. All Shell scripts also passed `bash -n`, and the Lua reference files passed syntax checks.

Coverage includes native/legacy Agents, argument validation, literal prompts, PATH conflicts, executable permission repair, backups, preservation of personal files,
48 screenshot backend/preference combinations, mismatches between PATH and `OMARCHY_PATH`, load order, TTY confirmation, and repeated runs.
Inconsistent PATH detection and missing executable permissions on a shim with identical content, both found during independent review, were fixed and covered by regression cases.

## Validation Boundaries

The following have not been completed and must not be considered passed:

- Hands-on experience of dragging, four-finger gestures, accidental-touch prevention, and scrolling direction.
- Physical screenshot hotkeys, annotation, notifications, scrolling screenshots, and interactions during screen sharing.
- Complete Chinese, Japanese, and English input, window state, hotkey switching, and terminal prefix combination tests for each input method.
- Lid closing, external displays, actual suspend/resume, and lock-screen security; these operations were deliberately not triggered during this validation.
- Complete live-system testing of native `agy`, the new screenshot wrapper, and input methods in a `quattro` desktop session.
- Long-term background service stability, resource overhead, and future availability of third-party APIs.

## Backups and Rollback

User configuration from before this validation's manual changes is saved in `~/.local/state/omarchy-skills-validation-20261031/`.
The Agent installer also outputs `<file>.backup.XXXXXX/original`, and the MacBook installer outputs
`<file>.macbook-backup.XXXXXX`. Before restoring, compare the current files and preserve personal changes made since validation;
do not overwrite blindly. Restoring the old layer rules will also reintroduce their known issues.

The background service can be disabled with `systemctl --user disable --now agy-daemon.service`;
to restore the old service, first compare the backups and restore approved content, then run `daemon-reload` and restart.
For removal of the MacBook managed blocks and modules, see the skill's "Verification and Rollback" section.
