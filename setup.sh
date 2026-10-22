#!/usr/bin/env bash
# Download a fixed Git revision, then use the same local bootstrap entry point.
set -euo pipefail

ref=main
if [[ "${1:-}" == --ref ]]; then
  ref="${2:?--ref requires a branch, tag, or commit}"
  shift 2
fi
if [[ "$(uname -s)" != Darwin ]]; then
  echo "This setup requires macOS." >&2
  exit 1
fi
if ! xcode-select --print-path >/dev/null 2>&1; then
  xcode-select --install
  echo "Complete Apple's command-line tools installation, then run setup again." >&2
  exit 1
fi

repo_dir="$HOME/repos/dotfiles"
repo_url=https://github.com/thiskevinwang/dotfiles.git
if [[ -e "$repo_dir" ]]; then
  [[ ! -L "$repo_dir" && -d "$repo_dir/.git" ]] || { echo "Unexpected checkout: $repo_dir" >&2; exit 1; }
  [[ "$(git -C "$repo_dir" remote get-url origin)" == "$repo_url" ]] || { echo "Unexpected origin." >&2; exit 1; }
  [[ -z "$(git -C "$repo_dir" status --porcelain)" ]] || { echo "Commit or save checkout changes before remote setup." >&2; exit 1; }
else
  mkdir -p "$(dirname "$repo_dir")"
  git clone "$repo_url" "$repo_dir"
fi
git -C "$repo_dir" fetch --no-tags origin "$ref"
git -C "$repo_dir" switch --detach FETCH_HEAD
exec bash "$repo_dir/bootstrap.sh" "$@"
