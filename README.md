# dotfiles

This is me managing my Dotfiles, CLI tools, Mac Apps, VSCode extensions.

The setup is a [Nix Flake](https://nixos.wiki/wiki/Flakes) so it is
reproducible and portable across macOS ([nix-darwin](https://github.com/LnL7/nix-darwin))
and Linux ([NixOS](https://nixos.org/) or standalone [home-manager](https://github.com/nix-community/home-manager)).

The legacy Homebrew/bash-script setup (`Brewfile`, `install.sh`) is kept
around as reference/fallback while the Nix migration settles in; see
[Legacy Homebrew setup](#legacy-homebrew-setup-macos-only) below.

## Quickstart (Nix)

1. Install Nix (multi-user install, works on both macOS and Linux):

   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

2. Clone this repo:

   ```bash
   git clone https://github.com/thiskevinwang/dotfiles.git
   cd dotfiles
   ```

3. Apply the configuration for your platform.

   **macOS (nix-darwin):**

   ```bash
   nix run nix-darwin -- switch --flake .#macbook
   ```

   **Linux (NixOS):**

   ```bash
   sudo nixos-rebuild switch --flake .#linux-desktop
   ```

   **Linux/macOS without root (standalone home-manager only):**

   ```bash
   nix run home-manager/release-24.11 -- switch --flake .#kevin@linux   # or .#kevin@darwin
   ```

After the first run, re-apply changes at any time with the same command.
Every step is declarative: re-running is idempotent, and `nix-darwin`/
`nixos-rebuild`/`home-manager` all support rolling back to the previous
generation if something breaks.

### Repo layout

```
flake.nix              # Entry point: inputs + system/home outputs
home/                  # home-manager modules, shared by every platform
  default.nix           # Wires up the other modules + home.stateVersion
  shells.nix            # zsh, oh-my-zsh, plugins, pure prompt
  editors.nix           # vim/neovim, VSCode, zed
  terminal.nix          # tmux (+ tmux-powerline), ghostty
  programs.nix          # CLI tools (previously in Brewfile)
nix/
  darwin.nix            # macOS system config (nix-darwin), e.g. Caps Lock remap
  linux.nix             # NixOS system config
```

### Customizing for your machine

- `flake.nix` defines a `defaultUser` and per-host entries
  (`darwinConfigurations.macbook`, `nixosConfigurations.linux-desktop`,
  `homeConfigurations."<user>@<linux|darwin>"`). Add a new attribute (e.g.
  copy `macbook`) if you're setting up an additional machine, and update
  `username`/`homeDirectory` to match.
- User-specific secrets (GPG signing key, local git overrides) are **not**
  managed by Nix. Create `~/.gitconfig.local` as documented in
  [Signed commits](#signed-commits) below; it's already referenced via
  `includeIf` in the tracked `gitconfig`.
- GUI-only apps (1Password, Docker Desktop, Slack, etc.) aren't installed
  by the flake. Install those manually, or add them via `homebrew.casks`
  in `nix/darwin.nix` if you also keep Homebrew around for casks
  (nix-darwin can manage Homebrew as a supplement).

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

## Legacy Homebrew setup (macOS only)

Prior to the Nix migration, this repo used Homebrew (`Brewfile`) and a bash
script (`install.sh`) to symlink dotfiles and install packages/casks. Both
are kept for reference, and still work if you'd rather not use Nix yet:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone https://github.com/thiskevinwang/dotfiles.git
cd dotfiles
sh install.sh
```

It is safe to run the Nix and Homebrew setups side-by-side during a
transition; home-manager only manages the files it's told about above.

