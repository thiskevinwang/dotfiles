# dotfiles

This is me managing my Dotfiles, Brew Binaries, Mac Apps, VSCode extensions


## Quickstart

Install Homebrew[^brew]

[^brew]: https://brew.sh/

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

(You might need a new terminal session for `brew` to be detected.)

```bash
git clone https://github.com/thiskevinwang/dotfiles.git
cd dotfiles
bash install.sh
```

## Linux setup

Run as the target user, without `sudo`. The script uses `sudo` for system packages.

```bash
git clone https://github.com/thiskevinwang/dotfiles.git
cd dotfiles
bash install-linux.sh --dry-run
bash install-linux.sh
```

Supports Debian/Ubuntu (`apt`), Fedora (`dnf`), and Arch (`pacman`). Arch setup
runs a full system upgrade before package installation. User tools require
an x86_64 or aarch64 Linux system and internet access.

Setup includes:

- Native CLI packages: Zsh, tmux, Vim, Neovim, Git, GPG, search and build tools.
- Available extras: GitHub CLI, Go, bat, fd, database clients, and other utilities.
- User tools: uv, fnm, Node.js LTS if Node/npm is missing, Bun, RTK, AWS CLI v2, Codex, Vercel.
- Oh My Zsh, autosuggestions, completions, Pure, TPM, tmux-powerline, editor plugins.
- Linux shell and tmux configs; shared Git, Vim, Nushell, Zed, and agent configs.
- VSCode extensions when the `code` command is installed.

Existing tools and plugin checkouts are kept. Config files that must change are
moved to `${XDG_STATE_HOME:-~/.local/state}/dotfiles/backups/<timestamp>-<pid>/`,
with their full original paths below that directory. Links already in place are
kept. Parent config directories are preserved. Keep this checkout in place.

```bash
bash install-linux.sh --config-only    # No downloads or package installation
bash install-linux.sh --skip-packages # System dependencies already installed
bash install-linux.sh --change-shell  # Also set Zsh as the login shell
bash install-linux.sh --help
```

Without `--change-shell`, start the shell with `exec zsh`. Put local shell
settings in `~/.zshrc.local`. XDG config, data, and state paths are supported.
Downloads use the upstream installers for [uv](https://docs.astral.sh/uv/getting-started/installation/),
[fnm](https://github.com/Schniz/fnm), [Bun](https://bun.sh/docs/installation), and
[RTK](https://github.com/rtk-ai/rtk). AWS CLI uses the
[official Linux installer](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
Codex and Vercel use npm with a user-local prefix. System dependencies must
already exist when packages are skipped. `--skip-tools` and `--skip-plugins`
can omit those stages separately.

Remaining manual steps:

- Override the repo's Git name/email in `~/.gitconfig.local` if needed.
- Sign in with `gh auth login`, `codex`, and `aws login` as needed.
- Create/import GPG keys and configure signing if needed.
- Install desktop apps, fonts, and tools unavailable in the enabled package repositories.
- Check `nvim`: current plugins can require a newer version than the native package.

The Linux script does not run the macOS Brewfile or install AWS Agent Toolkit.
Toolkit setup needs AWS sign-in and an interactive wizard; see the
[AWS setup guide](https://raw.githubusercontent.com/aws/agent-toolkit-for-aws/refs/heads/main/setup-instructions/setup.md).

Offline checks (no package installation):

```bash
python3 -B -m unittest discover -s tests -v
```

## Vim/Neovim

```console
❯ nvim

this starts a neovim session

❯ :PlugInstall

This installs all the specified plugins
```

## VSCode

Keybindings are here...

https://thekevinwang.com/atoms/01K993VJKY10E06E7AY2XAHRRM

## tmux setup

Install TPM and start tmux:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source-file ~/repos/dotfiles/tmux.conf
```

Inside tmux, press `Ctrl-b`, then `Shift-i` to install the configured plugins. This only needs to be done once per machine.

The install script links the tmux-powerline config and custom theme. Reload tmux after changes:

```sh
tmux source-file ~/.tmux.conf
```

## Misc Machine Setup
a
### Map `Caps Lock` (<kbd>⇪</kbd>) to `Control` (<kbd>⌃</kbd>)

![image](https://user-images.githubusercontent.com/26389321/131413420-45915f24-b0d9-4107-9205-2a2bc9e795d8.png)

### Signed commits

There are a few steps following the installation of `gnupg`:

- Generate a key
- Set the key id in a machine-specific config
- Upload the public key to GitHub


```console
user@~: $ gpg --full-generate-key
pub   ed25519 2025-12-01 [SC] [expires: 2027-12-01]
      KEY_ID
uid                      user (comment) <email>
sub   cv25519 2025-12-01 [E] [expires: 2027-12-01]

user@~: $ cat > ~/.gitconfig.local << 'EOF'
[user]
    signingkey = <KEY_ID>

[commit]
    gpgsign = true
EOF

user@~: $ git config --get commit.gpgsign
user@~: $ export GPG_TTY=$(tty) && echo "test" | gpg --clearsign
user@~: $ echo 'export GPG_TTY=$(tty)' >> ~/.zshrc && source ~/.zshrc
user@~: $ gpg --armor --export KEY_ID
# Upload this to https://github.com/settings/gpg/new
```
