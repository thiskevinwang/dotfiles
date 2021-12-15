# dotfiles

## oh-my-zsh

```sh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## `sh install.sh`

- This links config files to their respect dotfile locations
- <details>
    <summary><i>Example output</i></summary>

    ```console
    Linked Brewfile to /Users/kevin/.Brewfile.
    Linked gitconfig to /Users/kevin/.gitconfig.
    Linked vimrc to /Users/kevin/.vimrc.
    Linked zshrc to /Users/kevin/.zshrc.
    ```

  </details>

## `brew bundle`

- Installs everything in [Brewfile](./Brewfile)
  - binaries like `node`, `go`, `gh`, etc.
  - mac apps
  - 


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

# Misc

Caps Lock <kbd>⇪</kbd> ➜ Control <kbd>⌃</kbd>
- ![image](https://user-images.githubusercontent.com/26389321/131413420-45915f24-b0d9-4107-9205-2a2bc9e795d8.png)

Option <kbd>⌥</kbd> + <kbd>Delete</kbd> should delete words in terminal
- Option == Opt/Alt on HHKB
- ![image](https://user-images.githubusercontent.com/26389321/131890471-e80c74f4-2876-4390-bd80-1209618a0619.png)
