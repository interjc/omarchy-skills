#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/setup.sh"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

assert_eq() {
  local expected="$1"
  local actual="$2"
  local label="$3"
  if [[ "$expected" != "$actual" ]]; then
    echo "FAIL [$label]: expected '$expected', got '$actual'" >&2
    exit 1
  fi
}

assert_contains() {
  local needle="$1"
  local haystack="$2"
  local label="$3"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "FAIL [$label]: expected output to contain '$needle'" >&2
    echo "--- actual output ---" >&2
    echo "$haystack" >&2
    exit 1
  fi
}

make_sandbox() {
  local name="$1"
  local dir="$TMP_ROOT/$name"
  mkdir -p "$dir/home/.local/bin" "$dir/bin"
  printf '%s\n' "$dir"
}

write_mock_browse() {
  local target="$1"
  local log_file="$2"
  cat > "$target" <<EOF
#!/usr/bin/env bash
set -euo pipefail
echo "browse \$*" >> "$log_file"
case "\${1:-}" in
  status)
    echo "Setup:     installed"
    echo "Relay:     running at http://127.0.0.1:19988"
    echo "Extension: connected"
    ;;
  install)
    echo "✓ mock install ok: \$*"
    ;;
  pair)
    echo "Pairing code: TEST-1234"
    ;;
esac
EOF
  chmod +x "$target"
}

write_mock_curl() {
  local target="$1"
  local browse_dest="$2"
  local log_file="$3"
  local curl_log="$4"
  cat > "$target" <<EOF
#!/usr/bin/env bash
set -euo pipefail
echo "curl \$*" >> "$curl_log"
cat <<'INNER'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p "\$(dirname "$browse_dest")"
cat > "$browse_dest" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
echo "browse \$*" >> "$log_file"
case "\${1:-}" in
  status) echo "Setup: installed" ;;
  install) echo "✓ mock install ok: \$*" ;;
  pair) echo "Pairing code: MOCK-9999" ;;
esac
MOCK
chmod +x "$browse_dest"
echo "✓ mock installer placed browse"
INNER
EOF
  chmod +x "$target"
}

echo "==> Test 1: --help exits 0 without side effects"
out="$(bash "$SETUP_SCRIPT" --help)"
assert_contains "Usage: setup.sh" "$out" "help output"

echo "==> Test 2: non-interactive run without required flags fails before writing"
sb="$(make_sandbox missing-flags)"
set +e
out="$(HOME="$sb/home" PATH="$sb/bin:/usr/bin:/bin" bash "$SETUP_SCRIPT" </dev/null 2>&1)"
rc=$?
set -e
assert_eq "1" "$rc" "missing flags exit code"
assert_contains "Non-interactive run requires" "$out" "missing flags error message"

echo "==> Test 3: --status works read-only when browse is missing and when installed"
sb="$(make_sandbox status-only)"
out="$(HOME="$sb/home" PATH="$sb/bin:/usr/bin:/bin" bash "$SETUP_SCRIPT" --status)"
assert_contains "Binary:    not found" "$out" "status missing"
assert_contains "chromewebstore.google.com/detail/mfnicocicmmlkpjnaffgihfjhdgjkdjg" "$out" "status extension url"

write_mock_browse "$sb/home/.local/bin/browse" "$sb/browse.log"
out="$(HOME="$sb/home" PATH="$sb/bin:/usr/bin:/bin" bash "$SETUP_SCRIPT" --status)"
assert_contains "Extension: connected" "$out" "status installed"

echo "==> Test 4: --install yes downloads once, configures selected agents, and is idempotent"
sb="$(make_sandbox install-idempotent)"
write_mock_curl "$sb/bin/curl" "$sb/home/.local/bin/browse" "$sb/browse.log" "$sb/curl.log"

out="$(HOME="$sb/home" CURL_BIN="$sb/bin/curl" PATH="$sb/bin:/usr/bin:/bin" \
  bash "$SETUP_SCRIPT" --install yes --agents antigravity,codex --pair skip </dev/null)"
assert_contains "mock installer placed browse" "$out" "first run downloaded"
assert_contains "mock install ok: install -a antigravity -a codex --no-open --no-wait" "$out" "first run agents"
assert_eq "1" "$(wc -l < "$sb/curl.log" | tr -d ' ')" "curl called once"

out="$(HOME="$sb/home" CURL_BIN="$sb/bin/curl" PATH="$sb/bin:/usr/bin:/bin" \
  bash "$SETUP_SCRIPT" --install yes --agents antigravity,codex --pair skip </dev/null)"
assert_contains "already installed" "$out" "second run skips download"
assert_eq "1" "$(wc -l < "$sb/curl.log" | tr -d ' ')" "curl still called only once"

echo "==> Test 5: --agents all and --pair yes invoke expected commands"
sb="$(make_sandbox all-and-pair)"
write_mock_browse "$sb/home/.local/bin/browse" "$sb/browse.log"
out="$(HOME="$sb/home" PATH="$sb/bin:/usr/bin:/bin" \
  bash "$SETUP_SCRIPT" --install skip --agents all --pair yes --wait-seconds 45 </dev/null)"
assert_contains "Pairing code: TEST-1234" "$out" "pair output"
log_content="$(cat "$sb/browse.log")"
assert_contains "browse install -y --no-open --no-wait" "$log_content" "agents all call"
assert_contains "browse pair --wait-seconds 45" "$log_content" "pair wait seconds call"

echo "==> Test 6: --agents keep --pair skip performs no browse invocations"
sb="$(make_sandbox keep-skip)"
write_mock_browse "$sb/home/.local/bin/browse" "$sb/browse.log"
HOME="$sb/home" PATH="$sb/bin:/usr/bin:/bin" \
  bash "$SETUP_SCRIPT" --install skip --agents keep --pair skip </dev/null >/dev/null
if [[ -f "$sb/browse.log" ]]; then
  echo "FAIL [keep-skip]: expected no browse calls" >&2
  exit 1
fi

echo "==> Test 7: invalid --wait-seconds and --agents are rejected"
sb="$(make_sandbox invalid-args)"
set +e
HOME="$sb/home" PATH="$sb/bin:/usr/bin:/bin" \
  bash "$SETUP_SCRIPT" --install skip --agents keep --pair skip --wait-seconds 0 </dev/null >/dev/null 2>&1
rc1=$?
HOME="$sb/home" PATH="$sb/bin:/usr/bin:/bin" \
  bash "$SETUP_SCRIPT" --install skip --agents "bad agent!" --pair skip </dev/null >/dev/null 2>&1
rc2=$?
set -e
assert_eq "1" "$rc1" "reject zero wait-seconds"
assert_eq "1" "$rc2" "reject invalid agents spec"

echo "ALL TESTS PASSED"
