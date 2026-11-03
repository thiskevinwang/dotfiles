#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 is required. Install Apple's command-line tools, then run this command again." >&2
  xcode-select --install
  exit 1
fi
exec python3 "$repo_dir/scripts/bootstrap.py" "$@"
