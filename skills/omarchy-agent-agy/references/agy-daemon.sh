#!/usr/bin/env bash
set -euo pipefail

[[ $# == 1 && $1 == /* && -x $1 ]] || {
  printf 'Usage: agy-daemon.sh /absolute/path/to/agy\n' >&2
  exit 2
}

# Keep stdin open without sending requests. systemd owns the whole process group.
exec "$1" --input-format stream-json --output-format stream-json < <(sleep infinity)
