# dotfiles

This is me managing my Dotfiles, Brew Binaries, Mac Apps, VSCode extensions

## What My Setup Looks Like

>**Note**: Updated <time datetime="2022-06-09">June 9, 2022</time>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/26389321/172965684-4902db08-549d-4448-9d88-d8d0440d3311.png">
  <img alt="Screenshot of neovim setup" src="https://user-images.githubusercontent.com/26389321/172965870-1a8fa913-2597-45f2-9ea2-e22478bab9ca.png">
</picture>


## Quickstart

```bash
git clone https://github.com/thiskevinwang/dotfiles.git
cd dotfiles
sh install.sh
```

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


    💭 Run 'brew bundle'? [y/N] y
        Using homebrew/bundle
        Using homebrew/cask
        Using homebrew/core
        Using autojump
        Using awscli
        Using bat
        Using mas
        Using fnm
        Using fzf
        Using gh
        Using gnupg
        Using go
        Using kubectl
        Using neovim
        Using node
        Using ripgrep
        Using rust
        Using starship
        Using watchman
        Using 1password
        Using discord
        Using docker
        Using dropbox
        Using firefox
        Using google-chrome
        Using imageoptim
        Using istat-menus
        Using iterm2
        Using notion
        Using postman
        Using slack
        Using steam
        Using tableplus
        Using visual-studio-code
        Using zoom
        Using Compressor
        Using Final Cut Pro
        Using Magnet
        Using Xcode
        Homebrew Bundle complete! 39 Brewfile dependencies now installed.

    💭 Install VSCode extentions now? [y/N] y
        ✔ amazonwebservices.aws-toolkit-vscode
        ✔ apollographql.vscode-apollo
        ✔ bradlc.vscode-tailwindcss
        ✔ bradymholt.pgformatter
        ✔ ckolkman.vscode-postgres
        ✔ clinyong.vscode-css-modules
        ✔ codezombiech.gitignore
        ✔ csstools.postcss
        ✔ dbaeumer.vscode-eslint
        ✔ donjayamanne.githistory
        ✔ esbenp.prettier-vscode
        ✔ fwcd.kotlin
        ✔ GitHub.copilot
        ✔ GitHub.github-vscode-theme
        ✔ GitHub.vscode-pull-request-github
        ✔ golang.go
        ✔ GraphQL.vscode-graphql
        ✔ hashicorp.terraform
        ✔ hediet.vscode-drawio
        ✔ iocave.monkey-patch
        ✔ KnisterPeter.vscode-github
        ✔ MariusAlchimavicius.json-to-ts
        💥 matklad.rust-analyze
        ✔ mikestead.dotenv
        ✔ ms-azuretools.vscode-docker
        ✔ ms-kubernetes-tools.vscode-kubernetes-tools
        ✔ ms-python.python
        ✔ ms-toolsai.jupyter
        ✔ ms-vscode-remote.remote-containers
        💥 ms-vscode.typescript-javascript-grammar
        ✔ ms-vscode.vscode-typescript-next
        ✔ ms-vscode.vscode-typescript-tslint-plugin
        ✔ naumovs.color-highlight
        ✔ PKief.material-icon-theme
        ✔ Prisma.prisma
        ✔ redhat.vscode-commons
        ✔ redhat.vscode-yaml
        ✔ rust-lang.rust
        ✔ shakram02.bash-beautify
        ✔ shd101wyy.markdown-preview-enhanced
        ✔ silvenon.mdx
        ✔ streetsidesoftware.code-spell-checker
        ✔ tht13.html-preview-vscode
        ✔ Tyriar.lorem-ipsum
        ✔ VisualStudioExptTeam.vscodeintellicode
        ✔ vscjava.vscode-maven
        ✔ vscode-icons-team.vscode-icons
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

## Misc Machine Setup

### Map `Caps Lock` (<kbd>⇪</kbd>) to `Control` (<kbd>⌃</kbd>)

![image](https://user-images.githubusercontent.com/26389321/131413420-45915f24-b0d9-4107-9205-2a2bc9e795d8.png)

### Option <kbd>⌥</kbd> + <kbd>Delete</kbd> should delete words in terminal

Option == Opt/Alt on HHKB
![image](https://user-images.githubusercontent.com/26389321/131890471-e80c74f4-2876-4390-bd80-1209618a0619.png)
