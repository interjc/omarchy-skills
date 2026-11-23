#!/usr/bin/env bash
set -euo pipefail

BROWSE_BIN="${BROWSE_BIN:-$HOME/.local/bin/browse}"
INSTALL_URL="${INSTALL_URL:-https://opencode.ai/browse/install}"
CURL_BIN="${CURL_BIN:-curl}"
CHROME_EXTENSION_URL="https://chromewebstore.google.com/detail/mfnicocicmmlkpjnaffgihfjhdgjkdjg"

MODE_STATUS=0
OPT_INSTALL=""
OPT_AGENTS=""
OPT_PAIR=""
OPT_WAIT_SECONDS="180"

usage() {
  cat <<'EOF'
Usage: setup.sh [OPTIONS]

Configure opencode browse + Chrome extension for local development browser use.

Options:
  --status, --check-only     Read-only check of browse binary, relay, and pairing state
  --install <yes|skip>       Install browse via official script if missing, or skip installation
  --agents <spec>            Agent MCP setup: all | none | keep | comma-separated list
                             (e.g. antigravity,codex,claude,opencode)
  --pair <yes|skip>          Run `browse pair` to print a pairing code and wait for Chrome
  --wait-seconds <seconds>   Wait timeout for --pair yes (default: 180)
  -h, --help                 Show this help message and exit

Examples:
  # Read-only status check
  bash skills/omarchy-browser-use/scripts/setup.sh --status

  # Interactive wizard (prompts for missing preferences)
  bash skills/omarchy-browser-use/scripts/setup.sh

  # Non-interactive explicit setup
  bash skills/omarchy-browser-use/scripts/setup.sh \
    --install yes --agents antigravity,codex --pair yes --wait-seconds 180
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

resolve_browse_bin() {
  if [[ -x "$BROWSE_BIN" ]]; then
    printf '%s\n' "$BROWSE_BIN"
    return 0
  fi
  local from_path
  from_path="$(type -P browse 2>/dev/null || true)"
  if [[ -n "$from_path" && -x "$from_path" ]]; then
    printf '%s\n' "$from_path"
    return 0
  fi
  return 1
}

validate_positive_int() {
  local value="$1"
  [[ "$value" =~ ^[1-9][0-9]*$ ]]
}

validate_agents_spec() {
  local spec="$1"
  case "$spec" in
    all|none|keep)
      return 0
      ;;
  esac

  if [[ -z "$spec" ]]; then
    return 1
  fi

  local item
  IFS=',' read -r -a _items <<< "$spec"
  for item in "${_items[@]}"; do
    if [[ ! "$item" =~ ^[a-zA-Z0-9._-]+$ ]]; then
      return 1
    fi
  done
  return 0
}

run_status_check() {
  echo "==> Checking browse local development setup (read-only)"
  local resolved=""
  if resolved="$(resolve_browse_bin)"; then
    echo "Binary:    $resolved"
    "$resolved" status || true
  else
    echo "Binary:    not found (expected $BROWSE_BIN or browse in PATH)"
    echo "Next step: run setup.sh --install yes --agents <all|none|list> --pair yes"
  fi
  echo "Extension: $CHROME_EXTENSION_URL"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --status|--check-only)
        MODE_STATUS=1
        shift
        ;;
      --install)
        [[ $# -ge 2 ]] || die "--install requires a value (yes|skip)"
        OPT_INSTALL="$2"
        shift 2
        ;;
      --agents)
        [[ $# -ge 2 ]] || die "--agents requires a value (all|none|keep|comma-list)"
        OPT_AGENTS="$2"
        shift 2
        ;;
      --pair)
        [[ $# -ge 2 ]] || die "--pair requires a value (yes|skip)"
        OPT_PAIR="$2"
        shift 2
        ;;
      --wait-seconds)
        [[ $# -ge 2 ]] || die "--wait-seconds requires a positive integer"
        OPT_WAIT_SECONDS="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown argument: $1 (use --help for usage)"
        ;;
    esac
  done
}

prompt_missing_preferences() {
  if [[ -n "$OPT_INSTALL" && -n "$OPT_AGENTS" && -n "$OPT_PAIR" ]]; then
    return 0
  fi

  if [[ ! -t 0 || ! -t 1 ]]; then
    die "Non-interactive run requires explicit --install <yes|skip>, --agents <all|none|keep|list>, and --pair <yes|skip> (or use --status)"
  fi

  echo "==> Confirm preferences before making any changes"
  if [[ -z "$OPT_INSTALL" ]]; then
    if resolve_browse_bin >/dev/null 2>&1; then
      read -r -p "browse is already installed. Keep existing binary (skip) or run installer (yes)? [skip/yes]: " OPT_INSTALL
      OPT_INSTALL="${OPT_INSTALL:-skip}"
    else
      read -r -p "Install browse from ${INSTALL_URL}? [yes/skip]: " OPT_INSTALL
      OPT_INSTALL="${OPT_INSTALL:-skip}"
    fi
  fi

  if [[ -z "$OPT_AGENTS" ]]; then
    read -r -p "Which agents should browse configure? (all / none / keep / comma-list e.g. antigravity,codex): " OPT_AGENTS
  fi

  if [[ -z "$OPT_PAIR" ]]; then
    read -r -p "Generate a one-time Chrome pairing code now? [yes/skip]: " OPT_PAIR
    OPT_PAIR="${OPT_PAIR:-skip}"
  fi

  echo ""
  echo "Planned actions:"
  echo "  Install binary: $OPT_INSTALL"
  echo "  Agent MCP sync: $OPT_AGENTS"
  echo "  Pair Chrome:    $OPT_PAIR (wait: ${OPT_WAIT_SECONDS}s)"
  local confirm=""
  read -r -p "Proceed with these settings? [y/N]: " confirm
  case "$confirm" in
    y|Y|yes|YES)
      ;;
    *)
      echo "Aborted; no changes were made."
      exit 0
      ;;
  esac
}

validate_options() {
  case "$OPT_INSTALL" in
    yes|skip) ;;
    *) die "Invalid --install value: '$OPT_INSTALL' (expected yes or skip)" ;;
  esac

  if ! validate_agents_spec "$OPT_AGENTS"; then
    die "Invalid --agents value: '$OPT_AGENTS' (expected all, none, keep, or comma-separated agent names)"
  fi

  case "$OPT_PAIR" in
    yes|skip) ;;
    *) die "Invalid --pair value: '$OPT_PAIR' (expected yes or skip)" ;;
  esac

  if ! validate_positive_int "$OPT_WAIT_SECONDS"; then
    die "Invalid --wait-seconds value: '$OPT_WAIT_SECONDS' (expected positive integer)"
  fi
}

main() {
  parse_args "$@"

  if [[ "$MODE_STATUS" -eq 1 ]]; then
    run_status_check
    exit 0
  fi

  prompt_missing_preferences
  validate_options

  local resolved=""
  resolved="$(resolve_browse_bin || true)"

  echo "==> [1/3] Checking browse binary"
  if [[ "$OPT_INSTALL" == "yes" ]]; then
    if [[ -n "$resolved" ]]; then
      echo "browse is already installed at $resolved (skipping download)."
    else
      command -v "$CURL_BIN" >/dev/null 2>&1 || die "Required downloader not found: $CURL_BIN"
      echo "Downloading and installing browse from $INSTALL_URL ..."
      "$CURL_BIN" -fsSL "$INSTALL_URL" | bash -s -- --no-open --no-wait
      resolved="$(resolve_browse_bin || true)"
      [[ -n "$resolved" ]] || die "browse installation completed, but binary was not found at $BROWSE_BIN or in PATH"
    fi
  else
    if [[ -n "$resolved" ]]; then
      echo "Using existing browse binary: $resolved"
    else
      echo "Skipping browse installation (--install skip)."
    fi
  fi

  echo "==> [2/3] Configuring agent MCP entries"
  if [[ "$OPT_AGENTS" == "keep" ]]; then
    echo "Keeping existing agent MCP configurations unchanged."
  else
    [[ -n "$resolved" ]] || die "browse binary is required to configure agents (use --install yes)"
    if [[ "$OPT_AGENTS" == "all" ]]; then
      "$resolved" install -y --no-open --no-wait
    elif [[ "$OPT_AGENTS" == "none" ]]; then
      "$resolved" install -a none --no-open --no-wait
    else
      local -a agent_args=()
      local item
      IFS=',' read -r -a _agents <<< "$OPT_AGENTS"
      for item in "${_agents[@]}"; do
        agent_args+=(-a "$item")
      done
      "$resolved" install "${agent_args[@]}" --no-open --no-wait
    fi
  fi

  echo "==> [3/3] Chrome extension & pairing"
  echo "Chrome Web Store extension: $CHROME_EXTENSION_URL"
  if [[ "$OPT_PAIR" == "yes" ]]; then
    [[ -n "$resolved" ]] || die "browse binary is required to pair Chrome (use --install yes)"
    echo "Starting pairing flow (waiting up to ${OPT_WAIT_SECONDS}s)..."
    "$resolved" pair --wait-seconds "$OPT_WAIT_SECONDS"
  else
    echo "Skipping pairing (--pair skip). Run 'browse pair' whenever you are ready to connect Chrome."
  fi

  echo ""
  echo "Done. If your AI agents were already running, restart them so they load the browse MCP server."
  echo "You can use the browse CLI immediately (e.g., browse navigate http://localhost:3000 --keepVisible --keepOpen)."
}

main "$@"
