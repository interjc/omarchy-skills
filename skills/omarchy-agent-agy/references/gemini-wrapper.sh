#!/usr/bin/env bash
set -euo pipefail

# Legacy Omarchy only. This shadows every gemini call on the user's PATH.

args=()
while (($#)); do
  case "$1" in
    --yolo)
      args+=(--dangerously-skip-permissions)
      shift
      ;;
    --prompt-interactive|-i)
      (($# >= 2)) || { printf '%s needs a prompt\n' "$1" >&2; exit 2; }
      args+=(-i "$2")
      shift 2
      ;;
    --prompt|-p)
      (($# >= 2)) || { printf '%s needs a prompt\n' "$1" >&2; exit 2; }
      args+=(-p "$2")
      shift 2
      ;;
    --)
      args+=("$@")
      break
      ;;
    *)
      args+=("$1")
      shift
      ;;
  esac
done

exec agy "${args[@]}"
