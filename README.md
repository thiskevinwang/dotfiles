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
sh install.sh
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

