# dotfiles

## `sh install.sh`

This is the sauce...

- <details open>
    <summary><i>Output</i></summary>

    ```console
    🍻 Homebrew
            brew is installed

    ⚡️ Powerline fonts
            Copying fonts...
            Powerline fonts installed to /Users/kevin/Library/Fonts

    😮 Oh My Zsh
            Looks like Oh My Zsh is already installed

    🔗 Copying/Symlinking dotfiles
            · Linked Brewfile to /Users/kevin/.Brewfile.
            · Linked Brewfile.lock.json to /Users/kevin/.Brewfile.lock.json.
            · Linked gitconfig to /Users/kevin/.gitconfig.
            · Linked vimrc to /Users/kevin/.vimrc.
            · Linked zshrc to /Users/kevin/.zshrc.


    💭 Run 'brew bundle'? [y/N] 
            Skipping...

    💭 Install VSCode extentions now? [y/N] 
            Skipping...
    ```

  </details>


## VSCode

**TODOS**
- [ ] Programmatically install `code` CLI
- [ ] Sync `~/.vscode/extentions`

### `code` CLI

Installing `code` CLI
- In VSCode, <kbd>⌘</kbd> + <kbd>⇧</kbd> + <kbd>p</kbd>, search: "install code"

### Allowing <kbd>⌘</kbd> + <kbd>K</kbd> to clear the integrated terminal

In VSCode
- <kbd>⌘</kbd> + <kbd>⇧</kbd> + <kbd>p</kbd>
- search: ">Open Keyboard Shortcuts (JSON)"

```json
[
  {
    "key": "cmd+k",
    "command": "workbench.action.terminal.clear",
    "when": "terminalFocus && terminalProcessSupported"
  }
]
```

# Misc Machine Setup

## Map `Caps Lock` (<kbd>⇪</kbd>) to `Control` (<kbd>⌃</kbd>)

![image](https://user-images.githubusercontent.com/26389321/131413420-45915f24-b0d9-4107-9205-2a2bc9e795d8.png)

## Option <kbd>⌥</kbd> + <kbd>Delete</kbd> should delete words in terminal

Option == Opt/Alt on HHKB
![image](https://user-images.githubusercontent.com/26389321/131890471-e80c74f4-2876-4390-bd80-1209618a0619.png)
