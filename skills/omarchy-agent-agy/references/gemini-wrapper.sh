#!/bin/bash
# Wrapper redirecting Omarchy's legacy gemini agent calls to agy (Antigravity CLI)
# Location: ~/.local/bin/gemini

args=()
while (($#)); do
  case "$1" in
    --yolo)
      # Omarchy uses --yolo for unattended default agent launches
      args+=(--dangerously-skip-permissions)
      shift
      ;;
    --prompt-interactive|-i)
      # Interactive prompt argument mapping
      args+=(-i "$2")
      shift 2
      ;;
    --prompt|-p)
      # One-shot prompt argument mapping
      args+=(-p "$2")
      shift 2
      ;;
    *)
      args+=("$1")
      shift
      ;;
  esac
done

exec agy "${args[@]}"
