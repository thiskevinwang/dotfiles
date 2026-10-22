# dotfiles

macOS setup with nix-darwin and Home Manager. Nix installs CLI tools, fonts, and plugins. Homebrew installs app casks plus `dark-mode`, `vercel-cli`, `watchman`, and `postgresql@18`.

## Setup

From this checkout:

```sh
bash ./bootstrap.sh
```

The command selects `kevin-mac` on Apple Silicon or `kevin-intel` on Intel. Both configurations target user `kevin` and `/Users/kevin`. Change the user configuration in `flake.nix`, `nix/darwin.nix`, and `nix/home.nix` before use with another account.

On a new Mac, while this change is a draft:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/thiskevinwang/dotfiles/spike/nix-darwin-machine-setup/setup.sh) --ref spike/nix-darwin-machine-setup
```

The launcher clones or updates `~/repos/dotfiles`, selects the fetched Git revision, and runs the same bootstrap. It stops if an existing checkout has changes or a different origin. After merge, use the `main` URL and omit `--ref`.

Setup installs missing Nix and Homebrew prerequisites, builds the locked configuration, backs up existing config files, and activates nix-darwin. It then installs missing VS Code extensions and creates GPG agent settings only when absent. Apple command-line tools, administrator prompts, app sign-ins, and signing-key creation can need interaction. Run the same command again after an OS prerequisite finishes.

`sh install.sh` delegates to the same bootstrap. There is no separate legacy installer.

## Build without activation

```sh
bash ./bootstrap.sh --build-only
```

This requires Nix and Apple's command-line tools. It does not install prerequisites, adopt home files, run Homebrew, or activate the system.

## Configuration

| File | Owns |
| --- | --- |
| `flake.nix`, `flake.lock` | Host outputs and locked package/plugin sources |
| `nix/darwin.nix` | macOS settings and Homebrew activation |
| `nix/home.nix` | CLI tools, fonts, shell, and file mappings |
| `nix/editors.nix` | Vim/Neovim plugins and shared configuration |
| `Brewfile` | App casks and the four CLI/database exceptions |
| `scripts/bootstrap.py` | Prerequisites, file adoption, backups, and activation |

Nix keeps its existing installer and daemon owner: `nix.enable = false`. Bootstrap does not replace or downgrade the installed Nix version.

Nix CLI tools take priority over existing Homebrew binaries in a new shell. Existing Homebrew packages remain installed; automatic cleanup, updates, and upgrades are disabled. No database service or data directory is migrated. `doggo` replaces the unavailable `dog` package; `fastfetch` replaces deprecated `neofetch`.

Watchman stays in Homebrew because the pinned Nix `edencommon` dependency failed test discovery with a timeout during validation on this Mac.

Configuration files normally come from the Nix store. Edit their repo sources, then run bootstrap again. Zed settings remain writable through a checkout link at `~/.local/share/dotfiles/repo`. Credentials, application state, `~/.gitconfig.local`, and existing GPG agent settings remain local.

The generated Git configuration uses absolute Nix paths for GPG and the GitHub credential helper, including when Git runs from a GUI app.

Oh My Zsh, shell plugins, TPM, tmux-powerline, and Vim/Neovim plugins are installed from locked sources. Manual `PlugInstall` or TPM installation is unnecessary. Use the repo to update plugins; do not update their read-only directories in place.

The shell keeps optional Android, Bun, Terraform, Nomad, and local-script hooks. Those optional development environments are not installed by this configuration.

## Backups and recovery

Before activation, bootstrap moves only named config targets into:

```text
~/.local/state/dotfiles/backups/<timestamp>-<id>/
```

The backup includes a manifest and retains original files or links. A symlink in a parent directory, an unexpected directory, or a link owned by another checkout stops adoption before any moves. An activation failure attempts to restore adopted files. System changes can still be partial.

Restore a named file backup:

```sh
bash ./bootstrap.sh --restore ~/.local/state/dotfiles/backups/<timestamp>-<id>
```

Restoration stops when a new unrelated file would be overwritten. Backups remain available for manual recovery. nix-darwin generations do not roll back Homebrew versions, database data, app state, or writable Zed settings.

## Updates and checks

```sh
nix --extra-experimental-features 'nix-command flakes' flake update
bash ./bootstrap.sh
```

Ordinary setup uses `flake.lock` without updating it. Keep `system.stateVersion` and `home.stateVersion` fixed unless a documented migration requires a change.

```sh
python3 -m unittest discover -s tests -v
bash -n bootstrap.sh setup.sh install.sh
zsh -n zshrc
bash ./bootstrap.sh --build-only
python3 tests/check_runtime.py
```

## Git signing

Create a signing key separately and put machine settings in `~/.gitconfig.local`:

```gitconfig
[user]
    signingkey = <KEY_ID>
[commit]
    gpgsign = true
```

Use `git config --file ~/.gitconfig.local ...` for local edits. Upload the public key to GitHub. Account tokens and private keys are not stored in Nix configuration.
