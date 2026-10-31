#!/usr/bin/env bash
set -euo pipefail

skill_dir=$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")
sandbox=$(mktemp -d)
trap 'rm -rf -- "$sandbox"' EXIT
export HOME="$sandbox/home" OMARCHY_PATH="$sandbox/omarchy" TRACE="$sandbox/trace"
export PATH="$HOME/.local/bin:$sandbox/bin:/usr/bin:/bin"
mkdir -p "$HOME" "$sandbox/bin" "$OMARCHY_PATH/bin"

cat > "$sandbox/bin/agy" <<'MOCK'
#!/usr/bin/env bash
printf '<%s>\n' "$@" >> "$TRACE"
MOCK
cat > "$sandbox/bin/systemctl" <<'MOCK'
#!/usr/bin/env bash
printf 'systemctl %s\n' "$*" >> "$TRACE"
MOCK
cat > "$OMARCHY_PATH/bin/omarchy-agent" <<'MOCK'
#!/usr/bin/env bash
case "$agent" in
agy)
  command=(agy --dangerously-skip-permissions)
  ;;
esac
MOCK
cat > "$OMARCHY_PATH/bin/omarchy-default-agent" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
case "$1" in
agy | gemini) agent="agy" ;;
esac
mkdir -p "$HOME/.config/omarchy/defaults"
printf '%s\n' "$agent" > "$HOME/.config/omarchy/defaults/agent"
printf 'setter %s\n' "$*" >> "$TRACE"
MOCK
chmod +x "$sandbox/bin/agy" "$sandbox/bin/systemctl" "$OMARCHY_PATH/bin/omarchy-default-agent"

setup() { bash "$skill_dir/scripts/setup.sh" "$@" </dev/null; }
reject() {
  if setup "$@" > "$sandbox/error" 2>&1; then
    printf 'Expected failure: %s\n' "$*" >&2
    exit 1
  fi
}
snapshot() { tar -cf - -C "$HOME" . | sha256sum; }

# Every incomplete/invalid option must fail without changing HOME.
before=$(snapshot)
reject
reject --default-agent
reject --daemon
reject --agy-bin
reject --default-agent agy
reject --daemon enable
reject --default-agent agy --daemon
reject --default-agent invalid --daemon keep
reject --default-agent keep --daemon invalid
reject --default-agent keep --daemon keep --agy-bin /missing
reject --unknown
[[ $(snapshot) == "$before" ]]

# A real PTY exercises missing-preference prompts without approving any writes.
if command -v script >/dev/null; then
  printf -v tty_command 'bash %q' "$skill_dir/scripts/setup.sh"
  printf 'keep\nkeep\n' | script -q -e -c "$tty_command" /dev/null > "$sandbox/tty-output"
  grep -q 'Set agy as default?' "$sandbox/tty-output"
  grep -q 'Enable experimental background' "$sandbox/tty-output"
  [[ $(snapshot) == "$before" ]]
fi

# Native mapping uses the official setter and leaves unrelated customization alone.
mkdir -p "$HOME/.config/omarchy/extensions" "$HOME/.config/hypr" "$HOME/.config/ai-usagebar"
printf '// preserved JSONC\n{"custom": {"label": "Mine"}}\n' > "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
printf 'custom bindings\n' > "$HOME/.config/hypr/bindings.lua"
printf '[other]\nenabled = true\n' > "$HOME/.config/ai-usagebar/config.toml"
printf '{"version":1,"custom":true}\n' > "$HOME/.config/omarchy/shell.json"
setup --default-agent agy --daemon keep
[[ $(<"$HOME/.config/omarchy/defaults/agent") == agy ]]
[[ $(<"$TRACE") == 'setter agy' ]]
[[ ! -e $HOME/.local/bin/gemini && ! -e $HOME/.config/systemd ]]
before=$(snapshot)
setup --default-agent agy --daemon keep --legacy-shim
[[ $(snapshot) == "$before" && $(<"$TRACE") == 'setter agy' ]]

# Changing an existing default makes a recoverable backup.
printf 'claude\n' > "$HOME/.config/omarchy/defaults/agent"
setup --default-agent agy --daemon keep
shopt -s nullglob
backups=("$HOME/.config/omarchy/defaults/agent".backup.*/original)
[[ ${#backups[@]} == 1 && $(<"${backups[0]}") == claude ]]

# A setter that only starts asynchronous installation must not report completion.
cp "$OMARCHY_PATH/bin/omarchy-default-agent" "$sandbox/native-setter"
# Keep a recognizable branch but do not save the default.
cat > "$OMARCHY_PATH/bin/omarchy-default-agent" <<'MOCK'
#!/usr/bin/env bash
case "$1" in
agy | gemini) agent="agy" ;;
esac
exit 0
MOCK
printf 'claude\n' > "$HOME/.config/omarchy/defaults/agent"
reject --default-agent agy --daemon keep
[[ $(<"$HOME/.config/omarchy/defaults/agent") == claude ]]
cp "$sandbox/native-setter" "$OMARCHY_PATH/bin/omarchy-default-agent"
printf 'agy\n' > "$HOME/.config/omarchy/defaults/agent"

# Symlinks are not silently followed by the native setter.
mv "$HOME/.config/omarchy/defaults/agent" "$sandbox/linked-default"
ln -s "$sandbox/linked-default" "$HOME/.config/omarchy/defaults/agent"
before=$(snapshot)
reject --default-agent agy --daemon keep
[[ $(snapshot) == "$before" && $(<"$sandbox/linked-default") == agy ]]
rm "$HOME/.config/omarchy/defaults/agent"

# Verified legacy mapping requires opt-in; it does not call the old setter.
cat > "$OMARCHY_PATH/bin/omarchy-agent" <<'MOCK'
#!/usr/bin/env bash
case "$agent" in
gemini)
  command=(gemini --yolo)
  ;;
esac
MOCK
cat > "$OMARCHY_PATH/bin/omarchy-default-agent" <<'MOCK'
#!/usr/bin/env bash
case "$1" in
gemini | gemini-cli) agent="gemini" ;;
esac
exit 90
MOCK
before=$(snapshot)
reject --default-agent agy --daemon keep
[[ $(snapshot) == "$before" ]]
original_path=$PATH
export PATH="$sandbox/bin:/usr/bin:/bin"
reject --default-agent agy --daemon keep --legacy-shim
export PATH="$original_path"
printf '#!/usr/bin/env bash\nexit 0\n' > "$sandbox/bin/gemini"
chmod +x "$sandbox/bin/gemini"
export PATH="$sandbox/bin:$original_path"
reject --default-agent agy --daemon keep --legacy-shim
export PATH="$original_path"
rm "$sandbox/bin/gemini"
[[ $(snapshot) == "$before" ]]
mkdir -p "$HOME/.local/bin"
printf 'custom gemini\n' > "$HOME/.local/bin/gemini"
before=$(snapshot)
reject --default-agent agy --daemon keep --legacy-shim
[[ $(snapshot) == "$before" ]]
setup --default-agent agy --daemon keep --legacy-shim --replace-existing
[[ $(<"$HOME/.config/omarchy/defaults/agent") == gemini && -x $HOME/.local/bin/gemini ]]
backups=("$HOME/.local/bin/gemini".backup.*/original)
[[ ${#backups[@]} == 1 && $(<"${backups[0]}") == 'custom gemini' ]]
before=$(snapshot)
setup --default-agent agy --daemon keep --legacy-shim
[[ $(snapshot) == "$before" ]]

# Identical shim bytes without execute permission are repaired in place.
chmod -x "$HOME/.local/bin/gemini"
shim_inode=$(stat -c '%i' "$HOME/.local/bin/gemini")
setup --default-agent agy --daemon keep --legacy-shim
[[ -x $HOME/.local/bin/gemini && $(stat -c '%i' "$HOME/.local/bin/gemini") == "$shim_inode" ]]
cmp -s "$skill_dir/references/gemini-wrapper.sh" "$HOME/.local/bin/gemini"
[[ $(<"$HOME/.config/omarchy/defaults/agent") == gemini ]]
backups=("$HOME/.local/bin/gemini".backup.*/original)
[[ ${#backups[@]} == 1 ]]
before=$(snapshot)
setup --default-agent agy --daemon keep --legacy-shim
[[ $(snapshot) == "$before" ]]

# Strict wrapper: flag translation, quoting, -- terminator, missing prompt values.
: > "$TRACE"
"$HOME/.local/bin/gemini" --yolo --prompt-interactive 'two words' --prompt 'one shot' -- --yolo
expected=$'<--dangerously-skip-permissions>\n<-i>\n<two words>\n<-p>\n<one shot>\n<-->\n<--yolo>'
[[ $(<"$TRACE") == "$expected" ]]
for flag in --prompt-interactive -i --prompt -p; do
  case "$flag" in
    --prompt-interactive|-i) mapped_flag=-i ;;
    --prompt|-p) mapped_flag=-p ;;
  esac
  for value in '' --explain --yolo; do
    : > "$TRACE"
    "$HOME/.local/bin/gemini" "$flag" "$value"
    expected=$(printf '<%s>\n' "$mapped_flag" "$value")
    [[ $(<"$TRACE") == "$expected" ]]
  done
  if timeout 2s "$HOME/.local/bin/gemini" "$flag" > "$sandbox/error" 2>&1; then
    exit 1
  else
    [[ $? == 2 ]]
  fi
  [[ $(<"$TRACE") == "$expected" ]]
done

# Unknown/mixed capability fails closed, even when the legacy flag is present.
printf 'agy | gemini) agent="agy" ;;\n' >> "$OMARCHY_PATH/bin/omarchy-default-agent"
before=$(snapshot)
reject --default-agent agy --daemon keep --legacy-shim
[[ $(snapshot) == "$before" ]]

# Daemon opt-in uses an exact escaped path, without permission-bypass flags.
mkdir -p "$sandbox/bin with spaces"
cp "$sandbox/bin/agy" "$sandbox/bin with spaces/agy%\$special"
setup --default-agent keep --daemon enable --agy-bin "$sandbox/bin with spaces/agy%\$special"
service="$HOME/.config/systemd/user/agy-daemon.service"
grep -Fq 'bin with spaces/agy%%$$special' "$service"
! grep -q 'dangerously-skip-permissions' "$service"
[[ -x $HOME/.local/lib/omarchy-agent-agy/agy-daemon.sh ]]
before=$(snapshot)
setup --default-agent keep --daemon enable --agy-bin "$sandbox/bin with spaces/agy%\$special"
[[ $(snapshot) == "$before" ]]

# The identical daemon runner also regains execution without replacement.
runner="$HOME/.local/lib/omarchy-agent-agy/agy-daemon.sh"
chmod -x "$runner"
runner_inode=$(stat -c '%i' "$runner")
setup --default-agent keep --daemon enable --agy-bin "$sandbox/bin with spaces/agy%\$special"
[[ -x $runner && $(stat -c '%i' "$runner") == "$runner_inode" ]]
cmp -s "$skill_dir/references/agy-daemon.sh" "$runner"
backups=("$runner".backup.*/original)
[[ ${#backups[@]} == 0 ]]
before=$(snapshot)
setup --default-agent keep --daemon enable --agy-bin "$sandbox/bin with spaces/agy%\$special"
[[ $(snapshot) == "$before" ]]

printf '# custom service\n' >> "$service"
chmod -x "$runner"
before=$(snapshot)
reject --default-agent keep --daemon enable
[[ $(snapshot) == "$before" ]]
setup --default-agent keep --daemon enable --replace-existing
[[ -x $runner ]]
backups=("$service".backup.*/original)
[[ ${#backups[@]} == 1 ]]
grep -q '# custom service' "${backups[0]}"
before=$(snapshot)
setup --default-agent keep --daemon keep
[[ $(snapshot) == "$before" ]]

grep -q 'preserved JSONC' "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
[[ $(<"$HOME/.config/hypr/bindings.lua") == 'custom bindings' ]]
[[ $(<"$HOME/.config/ai-usagebar/config.toml") == $'[other]\nenabled = true' ]]
[[ $(<"$HOME/.config/omarchy/shell.json") == '{"version":1,"custom":true}' ]]

# Optional: execute the real pinned dispatch/setter scripts, with all launch,
# package-manager, and agent effects mocked. The checkout is read-only.
if [[ $# == 1 ]]; then
  upstream=$1
  cp "$sandbox/bin/agy" "$HOME/.local/bin/agy"
  cat > "$sandbox/bin/mise" <<'MOCK'
#!/usr/bin/env bash
exit 1
MOCK
  cat > "$sandbox/bin/omarchy-cmd-missing" <<'MOCK'
#!/usr/bin/env bash
exit 1
MOCK
  cat > "$sandbox/bin/omarchy-launch-tui" <<'MOCK'
#!/usr/bin/env bash
[[ $1 != --app-id=* ]] || shift
exec "$@"
MOCK
  chmod +x "$sandbox/bin/mise" "$sandbox/bin/omarchy-cmd-missing" "$sandbox/bin/omarchy-launch-tui"
  export PATH="$HOME/.local/bin:$sandbox/bin:$OMARCHY_PATH/bin:/usr/bin:/bin"
  for ref in bda3aaf6955404712dbd46541e6c8a75a2b16b7c v4.0.6; do
    git -C "$upstream" show "$ref:bin/omarchy-agent" > "$OMARCHY_PATH/bin/omarchy-agent"
    git -C "$upstream" show "$ref:bin/omarchy-default-agent" > "$OMARCHY_PATH/bin/omarchy-default-agent"
    chmod +x "$OMARCHY_PATH/bin/omarchy-agent" "$OMARCHY_PATH/bin/omarchy-default-agent"
    printf 'claude\n' > "$HOME/.config/omarchy/defaults/agent"
    : > "$TRACE"
    setup --default-agent agy --daemon keep --legacy-shim
    if [[ $ref == v4.0.6 ]]; then
      [[ $(<"$HOME/.config/omarchy/defaults/agent") == gemini ]]
      prompt_flag='<-i>'
    else
      [[ $(<"$HOME/.config/omarchy/defaults/agent") == agy ]]
      grep -q '<--dangerously-skip-permissions>' "$TRACE"
      prompt_flag='<--prompt-interactive>'
    fi
    : > "$TRACE"
    "$OMARCHY_PATH/bin/omarchy-agent" --inline --prompt 'literal prompt'
    [[ $(<"$TRACE") == $'<--dangerously-skip-permissions>\n'"$prompt_flag"$'\n<literal prompt>' ]]
    before=$(snapshot)
    setup --default-agent agy --daemon keep --legacy-shim
    [[ $(snapshot) == "$before" ]]
    printf 'PASS: actual upstream %s dispatch and mapping\n' "$ref"
  done
fi
printf 'PASS: native/legacy mapping, preflight safety, backups, wrapper, daemon, preservation, idempotency\n'
