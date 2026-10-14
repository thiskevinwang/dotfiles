#!/usr/bin/env bash
# Linux setup. Run as the target user; sudo is used only for system packages.
set -Eeuo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
dry_run=false
packages=true
tools=true
plugins=true
change_shell=false

usage() {
  cat <<'EOF'
Usage: bash install-linux.sh [options]
  --dry-run         Show actions without downloads, sudo, or file changes.
  --config-only     Link configs only; no packages, tools, or plugins.
  --skip-packages   Do not use the system package manager.
  --skip-tools      Do not install user-local tools or Node.js.
  --skip-plugins    Do not download shell, tmux, or editor plugins.
  --change-shell    Set Zsh as the login shell (can require a password).
  -h, --help        Show this help.

Supports apt (Debian/Ubuntu), dnf (Fedora), and pacman (Arch).
Existing configs are moved to ~/.local/state/dotfiles/backups/.
XDG_CONFIG_HOME, XDG_DATA_HOME, and XDG_STATE_HOME are supported.
EOF
}

for option in "$@"; do
  case "$option" in
    --dry-run) dry_run=true ;;
    --config-only) packages=false; tools=false; plugins=false ;;
    --skip-packages) packages=false ;;
    --skip-tools) tools=false ;;
    --skip-plugins) plugins=false ;;
    --change-shell) change_shell=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$option" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ $(uname -s) != Linux ]] && ! $dry_run; then
  printf 'Linux required. Use install.sh on macOS.\n' >&2
  exit 1
fi
if [[ -n ${SUDO_USER:-} && ${SUDO_USER} != root ]]; then
  printf 'Run without sudo. Only package commands need sudo.\n' >&2
  exit 1
fi

config_dir=${XDG_CONFIG_HOME:-$HOME/.config}
data_dir=${XDG_DATA_HOME:-$HOME/.local/share}
state_dir=${XDG_STATE_HOME:-$HOME/.local/state}
backup_dir="$state_dir/dotfiles/backups/$(date -u +%Y%m%dT%H%M%SZ)-$$"
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$data_dir/fnm:$PATH"
work_dir=''
cleanup() { [[ -z $work_dir ]] || rm -rf -- "$work_dir"; }
trap cleanup EXIT
trap 'printf "Setup failed at line %s. Fix the error, then run again.\n" "$LINENO" >&2' ERR

log() { printf '\n%s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }
run() {
  if $dry_run; then
    printf '  +'; printf ' %q' "$@"; printf '\n'
  else
    "$@"
  fi
}

backup() {
  local target=$1 destination="$backup_dir/${1#/}"
  if [[ -e $target || -L $target ]]; then
    run mkdir -p -- "$(dirname -- "$destination")"
    run mv -- "$target" "$destination"
  fi
}

link_file() {
  local source=$1 target=$2
  if [[ -L $target && $(readlink -- "$target") == "$source" ]]; then
    return
  fi
  backup "$target"
  run mkdir -p -- "$(dirname -- "$target")"
  run ln -s -- "$source" "$target"
}

write_file() {
  local target=$1 content=$2
  if $dry_run; then
    printf '  Write %s (back up if changed)\n' "$target"
    return
  fi
  if [[ -f $target ]] && cmp -s -- "$target" <(printf '%s\n' "$content"); then
    return
  fi
  backup "$target"
  mkdir -p -- "$(dirname -- "$target")"
  printf '%s\n' "$content" > "$target"
}

clone() {
  local repository=$1 target=$2
  if [[ -d $target/.git ]]; then
    return
  fi
  if [[ -e $target || -L $target ]]; then
    printf 'Keep existing directory: %s\n' "$target"
    return
  fi
  run mkdir -p -- "$(dirname -- "$target")"
  run git clone --depth 1 "$repository" "$target"
}

install_packages() {
  local manager package
  local -a admin=() base=() extra=() available=() install=()
  if [[ $EUID != 0 ]]; then
    if ! have sudo && ! $dry_run; then
      printf 'sudo required for packages. Use --skip-packages if already installed.\n' >&2
      return 1
    fi
    admin=(sudo)
  fi
  if have apt-get; then
    manager=apt
    base=(build-essential ca-certificates curl git gnupg unzip zip zsh tmux vim neovim ripgrep fzf jq python3)
    extra=(bat fd-find gh golang-go cmake mercurial tree watchman webp xclip pinentry-curses postgresql-client git-lfs lsd btop)
    run "${admin[@]}" apt-get update
    install=("${admin[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y)
  elif have dnf; then
    manager=dnf
    base=(gcc gcc-c++ make ca-certificates curl git gnupg2 unzip zip zsh tmux vim-enhanced neovim ripgrep fzf jq python3)
    extra=(bat fd-find gh golang cmake mercurial tree watchman libwebp-tools xclip pinentry-tty postgresql git-lfs lsd btop)
    install=("${admin[@]}" dnf install -y)
  elif have pacman; then
    manager=pacman
    base=(base-devel ca-certificates curl git gnupg unzip zip zsh tmux vim neovim ripgrep fzf jq python)
    extra=(bat fd github-cli go cmake mercurial tree watchman libwebp xclip pinentry postgresql git-lfs lsd bottom nushell yq)
    # Arch requires a full upgrade when refreshing package databases.
    run "${admin[@]}" pacman -Syu --noconfirm
    install=("${admin[@]}" pacman -S --needed --noconfirm)
  else
    if $dry_run; then
      printf '  Install native packages with apt, dnf, or pacman on Linux.\n'
      return
    fi
    printf 'No supported package manager. Install dependencies, then use --skip-packages.\n' >&2
    return 1
  fi
  run "${install[@]}" "${base[@]}"
  for package in "${extra[@]}"; do
    if $dry_run; then
      available+=("$package")
    elif { [[ $manager == apt ]] && apt-cache show "$package" >/dev/null 2>&1; } ||
         { [[ $manager == dnf ]] && dnf -q info "$package" >/dev/null 2>&1; } ||
         { [[ $manager == pacman ]] && pacman -Si "$package" >/dev/null 2>&1; }; then
      available+=("$package")
    else
      printf 'Package unavailable; skip: %s\n' "$package"
    fi
  done
  if ((${#available[@]})); then
    run "${install[@]}" "${available[@]}"
  fi
}

# Download first so failed HTTP requests cannot execute partial scripts.
installer() {
  local name=$1 url=$2 interpreter=$3
  shift 3
  run curl -fsSL --retry 3 "$url" -o "$work_dir/$name.sh"
  run "$interpreter" "$work_dir/$name.sh" "$@"
}

install_tools() {
  local arch
  have uv || UV_INSTALL_DIR="$HOME/.local/bin" UV_NO_MODIFY_PATH=1 installer uv https://astral.sh/uv/install.sh sh
  have fnm || installer fnm https://fnm.vercel.app/install bash --skip-shell --install-dir "$data_dir/fnm"
  if ! have node || ! have npm; then
    if ! $dry_run; then eval "$(fnm env --shell bash)"; fi
    run fnm install --lts --use
  fi
  have bun || installer bun https://bun.sh/install bash
  have rtk || installer rtk https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh sh
  if ! have aws; then
    arch=$(uname -m)
    case "$arch" in
      x86_64|aarch64) ;;
      *) printf 'AWS CLI requires x86_64 or aarch64.\n' >&2; return 1 ;;
    esac
    run curl -fsSL --retry 3 "https://awscli.amazonaws.com/awscli-exe-linux-$arch.zip" -o "$work_dir/aws.zip"
    run unzip -q "$work_dir/aws.zip" -d "$work_dir"
    run "$work_dir/aws/install" --install-dir "$HOME/.local/lib/aws-cli" --bin-dir "$HOME/.local/bin" --update
  fi
  # A user prefix also works when Node came from a system package.
  have codex || run npm install --global --prefix "$HOME/.local" @openai/codex
  have vercel || run npm install --global --prefix "$HOME/.local" vercel
}

log 'Linux packages'
$packages && install_packages
if $tools || $plugins; then
  if $dry_run; then
    work_dir='/tmp/dotfiles-preview'
    # Do not clean this preview path: it was never created by this process.
    trap - EXIT
  else
    for dependency in curl git unzip; do
      if ! have "$dependency"; then
        printf 'Missing dependency: %s\n' "$dependency" >&2
        exit 1
      fi
    done
    work_dir=$(mktemp -d)
  fi
fi
log 'User tools'
$tools && install_tools

# Debian names these binaries batcat and fdfind.
for mapping in bat:batcat fd:fdfind; do
  name=${mapping%%:*}
  alternate=${mapping#*:}
  if ! have "$name" && have "$alternate"; then
    link_file "$(command -v "$alternate")" "$HOME/.local/bin/$name"
  fi
done

log 'Configuration (existing files are backed up)'
link_file "$SCRIPT_DIR/zshrc.linux" "${ZDOTDIR:-$HOME}/.zshrc"
link_file "$SCRIPT_DIR/gitconfig" "$HOME/.gitconfig"
link_file "$SCRIPT_DIR/gitignore" "$HOME/.gitignore"
link_file "$SCRIPT_DIR/vimrc" "$HOME/.vimrc"
link_file "$SCRIPT_DIR/tmux.conf.linux" "$HOME/.tmux.conf"
link_file "$SCRIPT_DIR/nushell/config.nu" "$config_dir/nushell/config.nu"
link_file "$SCRIPT_DIR/zed/settings.json" "$config_dir/zed/settings.json"
link_file "$SCRIPT_DIR/tmux-powerline/config.sh" "$config_dir/tmux-powerline/config.sh"
link_file "$SCRIPT_DIR/tmux-powerline/theme.sh" "$config_dir/tmux-powerline/themes/theme.sh"
write_file "$config_dir/nvim/init.vim" 'set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc'

# Use this Linux user's home in the imported agent rules.
rules=$(<"$SCRIPT_DIR/AGENTS.md")
rules=${rules//@\/Users\/kevin\/.codex\/RTK.md/@$HOME/.codex/RTK.md}
for target in "$HOME/.codex/AGENTS.md" "$HOME/.claude/CLAUDE.md" "$config_dir/zed/AGENTS.md"; do
  write_file "$target" "$rules"
done
write_file "$HOME/.codex/RTK.md" 'Prefix shell commands with rtk. Use rtk proxy for unsupported commands.'

if $plugins; then
  log 'Shell and tmux plugins'
  zsh_dir=${ZSH:-$HOME/.oh-my-zsh}
  custom_dir=${ZSH_CUSTOM:-$zsh_dir/custom}
  clone https://github.com/ohmyzsh/ohmyzsh.git "$zsh_dir"
  clone https://github.com/zsh-users/zsh-autosuggestions.git "$custom_dir/plugins/zsh-autosuggestions"
  clone https://github.com/zsh-users/zsh-completions.git "$custom_dir/plugins/zsh-completions"
  clone https://github.com/sindresorhus/pure.git "$custom_dir/pure"
  clone https://github.com/tmux-plugins/tpm.git "$HOME/.tmux/plugins/tpm"
  clone https://github.com/erikw/tmux-powerline.git "$HOME/.tmux/plugins/tmux-powerline"

  log 'Editor plugins'
  run mkdir -p "$HOME/.vim/autoload" "$HOME/.vim/backup" "$HOME/.vim/swap" "$HOME/.vim/cache" "$HOME/.vim/undo"
  if [[ ! -f $HOME/.vim/autoload/plug.vim ]]; then
    run curl -fsSL --retry 3 https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -o "$HOME/.vim/autoload/plug.vim"
  fi
  # Install without loading Lua modules before their plugins exist.
  if $dry_run; then
    printf '  Extract the Vim plugin list to a temporary bootstrap config.\n'
  else
    sed -n '/^call plug#begin()/,/^call plug#end()/p' "$SCRIPT_DIR/vimrc" > "$work_dir/plugins.vim"
  fi
  if have vim || $dry_run; then
    run vim -N -u NONE -i NONE -n -es --cmd 'set rtp+=~/.vim' \
      -S "$work_dir/plugins.vim" -c 'PlugInstall --sync' -c 'qa!'
  fi
  if have nvim || $dry_run; then
    run nvim --headless -u NONE -i NONE --cmd 'set rtp+=~/.vim' \
      -S "$work_dir/plugins.vim" -c 'PlugInstall --sync' -c 'qa!'
  else
    printf 'Neovim missing; editor plugins skipped.\n'
  fi
  if have code; then
    while IFS= read -r extension || [[ -n $extension ]]; do
      [[ -z $extension ]] || run code --install-extension "$extension"
    done < "$SCRIPT_DIR/.vscode/extensions.txt"
  fi
fi

if $change_shell; then
  if have zsh; then
    run chsh -s "$(command -v zsh)"
  elif $dry_run; then
    printf '  Set Zsh as the login shell after package installation.\n'
  else
    printf 'Zsh missing; cannot change the login shell.\n' >&2
    exit 1
  fi
fi

log 'Setup finished. Start Zsh with: exec zsh'
printf 'Backup location (if files changed): %s\n' "$backup_dir"
printf 'Manual steps: gh auth login; codex; aws login; optional GPG key setup.\n'
printf 'Git identity comes from this repo. Override it in ~/.gitconfig.local.\n'
printf 'Neovim plugins can require a newer Neovim than the distribution provides.\n'
