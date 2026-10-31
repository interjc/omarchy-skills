#!/usr/bin/env bash
set -euo pipefail

fail() { printf 'setup: %s\n' "$*" >&2; exit 1; }
usage() {
  printf '%s\n' \
    'Usage: setup.sh [--default-agent agy|keep] [--daemon enable|keep]' \
    '                [--legacy-shim] [--replace-existing] [--agy-bin /absolute/path]' \
    'TTY: ask for missing preferences before writing anything.' \
    'Noninteractive: both --default-agent and --daemon are required.' \
    '--legacy-shim: allow the gemini shim ONLY on detected legacy Omarchy.' \
    '--replace-existing: back up and replace conflicting shim/daemon files.' \
    '--agy-bin: executable for the optional daemon (default: resolve agy on PATH).' \
    'Does not install plugins or edit menus, keybindings, TOML, or shell.json.' \
    'Warning: Omarchy agent launches bypass permission prompts.'
}

default_agent='' daemon='' agy_bin=''
legacy_shim=false replace_existing=false
while (($#)); do
  case "$1" in
    --default-agent|--daemon|--agy-bin)
      (($# >= 2)) && [[ -n $2 && $2 != --* ]] || fail "$1 needs a value"
      case "$1" in
        --default-agent) default_agent=$2 ;;
        --daemon) daemon=$2 ;;
        --agy-bin) agy_bin=$2 ;;
      esac
      shift 2 ;;
    --legacy-shim) legacy_shim=true; shift ;;
    --replace-existing) replace_existing=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) fail "unknown option: $1" ;;
  esac
done

[[ -z $default_agent || $default_agent == agy || $default_agent == keep ]] || fail 'invalid --default-agent'
[[ -z $daemon || $daemon == enable || $daemon == keep ]] || fail 'invalid --daemon'
if [[ -t 0 && -t 1 ]]; then
  if [[ -z $default_agent ]]; then
    printf 'Set agy as default? Omarchy launches bypass permission prompts. [agy/keep]: '
    read -r default_agent || fail 'cancelled'
  fi
  if [[ -z $daemon ]]; then
    printf 'Enable experimental background stream-json service (no permission-bypass flag)? [enable/keep]: '
    read -r daemon || fail 'cancelled'
  fi
fi
[[ $default_agent == agy || $default_agent == keep ]] || fail 'choose --default-agent agy|keep'
[[ $daemon == enable || $daemon == keep ]] || fail 'choose --daemon enable|keep'
[[ -z $agy_bin || $daemon == enable ]] || fail '--agy-bin requires --daemon enable'

skill_dir=$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")
omarchy_path=${OMARCHY_PATH:-/usr/share/omarchy}
agent_file="$HOME/.config/omarchy/defaults/agent"
mode=keep
if [[ $default_agent == agy ]]; then
  dispatcher="$omarchy_path/bin/omarchy-agent"
  setter="$omarchy_path/bin/omarchy-default-agent"
  [[ -r $dispatcher && -x $setter ]] || fail 'cannot inspect installed Omarchy agent scripts; check OMARCHY_PATH'
  command -v agy >/dev/null || fail 'install and authenticate agy before choosing the default'
  # Match executable case branches, not help text or a guessed version number.
  if grep -Eq '^[[:space:]]*agy\)' "$dispatcher" &&
    grep -Eq '^[[:space:]]*agy[[:space:]|)].*agent="agy"' "$setter"; then
    mode=native
  elif grep -Eq '^[[:space:]]*gemini\)' "$dispatcher" &&
    grep -Eq '^[[:space:]]*gemini[[:space:]|)].*agent="gemini"' "$setter" &&
    ! grep -Eq 'agent="agy"' "$setter"; then
    mode=legacy
    if [[ $legacy_shim == false && -t 0 && -t 1 ]]; then
      printf 'Legacy Omarchy detected. Redirect ALL gemini calls via ~/.local/bin/gemini? [yes/no]: '
      read -r answer || fail 'cancelled'
      [[ $answer == yes ]] && legacy_shim=true
    fi
    [[ $legacy_shim == true ]] || fail 'legacy Omarchy requires explicit --legacy-shim approval'
    # Do not change PATH or uninstall another CLI to force the shim to win.
    path_ready=false
    IFS=: read -ra path_entries <<< "$PATH"
    for entry in "${path_entries[@]}"; do
      if [[ $entry == "$HOME/.local/bin" ]]; then path_ready=true; break; fi
      [[ ! -x ${entry:-.}/gemini ]] || fail 'another gemini precedes ~/.local/bin on PATH; review PATH first'
    done
    [[ $path_ready == true ]] || fail 'put ~/.local/bin on PATH before using the legacy shim'
  else
    fail 'unrecognized Omarchy agent capabilities; refusing a guessed compatibility path'
  fi
fi

targets=() contents=() modes=()
if [[ $mode == legacy ]]; then
  targets+=("$HOME/.local/bin/gemini")
  contents+=("$(<"$skill_dir/references/gemini-wrapper.sh")")
  modes+=(755)
fi
if [[ $daemon == enable ]]; then
  command -v systemctl >/dev/null || fail 'systemctl is required for the optional daemon'
  agy_bin=${agy_bin:-$(command -v agy || true)}
  [[ $agy_bin == /* && -f $agy_bin && -x $agy_bin ]] || fail '--agy-bin must resolve to an executable absolute path'
  agy_bin=$(realpath -- "$agy_bin")
  [[ $agy_bin != *$'\n'* && $agy_bin != *$'\r'* ]] || fail 'unsupported newline in executable path'
  # Escape systemd unit syntax, not shell syntax. The runner receives one argument.
  unit_agy=${agy_bin//\\/\\\\}
  unit_agy=${unit_agy//\"/\\\"}
  unit_agy=${unit_agy//%/%%}
  unit_agy=${unit_agy//\$/\$\$}
  service_content=$(<"$skill_dir/references/agy-daemon.service")
  service_content=${service_content//@AGY_BIN@/"$unit_agy"}
  targets+=("$HOME/.local/lib/omarchy-agent-agy/agy-daemon.sh" "$HOME/.config/systemd/user/agy-daemon.service")
  contents+=("$(<"$skill_dir/references/agy-daemon.sh")" "$service_content")
  modes+=(755 644)
fi

# Finish conflict checks before creating directories, backups, or default files.
for i in "${!targets[@]}"; do
  target=${targets[i]}
  [[ ! -d $target ]] || fail "refusing to replace directory: $target"
  if [[ -e $target || -L $target ]]; then
    if [[ ! -L $target && -f $target ]] && cmp -s -- "$target" <(printf '%s\n' "${contents[i]}"); then
      if [[ ${modes[i]} == 755 && ! -x $target ]]; then
        [[ -O $target ]] || fail "cannot repair executable permission on unowned file: $target"
      fi
      continue
    fi
    [[ $replace_existing == true ]] || fail "existing customization: $target (review first; --replace-existing backs it up)"
  fi
done
[[ $mode == keep || ( ! -d $agent_file && ! -L $agent_file ) ]] || fail "refusing directory or symlink default file: $agent_file"

backup() {
  local destination
  destination=$(mktemp -d "${1}.backup.XXXXXX")
  cp -a -- "$1" "$destination/original"
  printf 'Backup: %s/original\n' "$destination"
}

daemon_changed=false
for i in "${!targets[@]}"; do
  target=${targets[i]}
  if [[ ! -L $target && -f $target ]] && cmp -s -- "$target" <(printf '%s\n' "${contents[i]}"); then
    if [[ ${modes[i]} == 755 && ! -x $target ]]; then
      chmod u+x -- "$target"
      [[ -x $target ]] || fail "executable permission repair failed: $target"
    fi
    continue
  fi
  mkdir -p -- "$(dirname -- "$target")"
  if [[ -e $target || -L $target ]]; then backup "$target"; fi
  temporary=$(mktemp "${target}.tmp.XXXXXX")
  printf '%s\n' "${contents[i]}" > "$temporary"
  chmod "${modes[i]}" "$temporary"
  mv -T -- "$temporary" "$target"
  [[ $target == "$HOME/.local/bin/gemini" ]] || daemon_changed=true
done

if [[ $mode != keep ]]; then
  desired=agy
  [[ $mode != legacy ]] || desired=gemini
  current=''
  if [[ -f $agent_file ]]; then current=$(<"$agent_file"); fi
  if [[ $current != "$desired" ]]; then
    if [[ -e $agent_file || -L $agent_file ]]; then backup "$agent_file"; fi
    if [[ $mode == native ]]; then
      printf 'Using native omarchy-default-agent agy (may install via mise and launch a terminal).\n'
      "$setter" agy
      [[ -f $agent_file && $(<"$agent_file") == agy ]] ||
        fail 'native setter has not saved agy; finish any launched installation and rerun'
    else
      # Only the verified legacy setter/dispatcher retain the gemini identifier.
      mkdir -p -- "$(dirname -- "$agent_file")"
      temporary=$(mktemp "${agent_file}.tmp.XXXXXX")
      printf 'gemini\n' > "$temporary"
      chmod 644 "$temporary"
      mv -T -- "$temporary" "$agent_file"
    fi
  fi
fi
if [[ $daemon == enable ]]; then
  systemctl --user daemon-reload
  systemctl --user enable --now agy-daemon.service
  if [[ $daemon_changed == true ]]; then systemctl --user restart agy-daemon.service; fi
fi
printf 'Setup complete: mapping=%s, daemon=%s. Menus, shortcuts, and usagebar config were not changed.\n' "$mode" "$daemon"
