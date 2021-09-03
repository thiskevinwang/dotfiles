# dotfiles

Some commands to help get a new workstation set up, and some config files to copy into `~/`.

## FiraCode Font

Also see: [nerdfonts](https://www.nerdfonts.com/)

https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip

## Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Github CLI

```sh
brew install gh
```

## oh-my-zsh

```sh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### starship 

```sh
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
# or
brew install starship
```

`~/.zshrc`

```
eval "$(starship init zsh)"
```

## zsh things

zsh completions

```sh
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
```

[fzf](https://github.com/junegunn/fzf)

```sh
brew install fzf
```

autojump

```sh
brew install autojump
```

znap

```sh
git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git
source zsh-snap/install.zsh
```

autocomplete

```sh
znap source marlonrichert/zsh-autocomplete
```

## VSCode

### `code` CLI

Installing `code` CLI
- In VSCode, <kbd>⌘</kbd> + <kbd>⇧</kbd> + <kbd>p</kbd>, search: "install code"

### Integrated Terminal

Allowing <kbd>⌘</kbd> + <kbd>K</kbd> to clear the integrated terminal

- In VSCode, <kbd>⌘</kbd> + <kbd>⇧</kbd> + <kbd>p</kbd>, search: ">Open Keyboard Shortcuts (JSON)"
  ```json
  // Place your key bindings in this file to override the defaults
  [
    {
      "key": "cmd+k",
      "command": "workbench.action.terminal.clear",
      "when": "terminalFocus && terminalProcessSupported"
    }
  ]
  ```

## Commands

```sh
git config --global user.name "Kevin Wang"
git config --global user.email "FIXME"
```

# Misc

Caps Lock <kbd>⇪</kbd> ➜ Control <kbd>⌃</kbd>
- ![image](https://user-images.githubusercontent.com/26389321/131413420-45915f24-b0d9-4107-9205-2a2bc9e795d8.png)

Option <kbd>⌥</kbd> + <kbd>Delete</kbd> should delete words in terminal
- Option == Opt/Alt on HHKB
- ![image](https://user-images.githubusercontent.com/26389321/131890471-e80c74f4-2876-4390-bd80-1209618a0619.png)
