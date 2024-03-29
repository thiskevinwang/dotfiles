# dotfiles

This is me managing my Dotfiles, Brew Binaries, Mac Apps, VSCode extensions

## What My Setup Looks Like

![CleanShot 2023-10-09 at 08 33 30@2x](https://github.com/thiskevinwang/dotfiles/assets/26389321/d753b088-1519-4fb7-b838-4505bbe39ec5#gh-light-mode-only)
![CleanShot 2023-10-09 at 08 34 03@2x](https://github.com/thiskevinwang/dotfiles/assets/26389321/7a9b20d3-016f-47e2-9c1f-104a411fb2e4#gh-dark-mode-only)

> [!WARNING]
>
> VSCode and iTerm are my two daily tools. I no longer use vim/nvim, nor never really understood how to get around efficiently, so all vim settings here will not really be maintained.

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

## `sh install.sh`

Run this to install all the things.

## Vim/Neovim

To avoid vim errors / noise, for example, when using the interactive `git rebase` which runs in neovim for me, run:

```console
❯ nvim

this starts a neovim session

❯ :PlugInstall

This installs all the specified plugins
```

- [ ] TODO: skip this manual step 👆

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

### iTerm2 Colors

Download the `*.itermcolors` from https://github.com/cdalvaro/github-vscode-theme-iterm and import them via iTerm2

Settings → Profiles → Colors → Color Presets → Import...

### Auto dark mode

```bash
# copy the below into clipboard
pbpaste > /Users/kevin/Library/Application\ Support/iTerm2/Scripts/AutoLaunch/auto_dark_mode.py
```

```python
#!/usr/bin/env python3

import iterm2

async def main(connection):
    async with iterm2.VariableMonitor(connection, iterm2.VariableScopes.APP, "effectiveTheme", None) as mon:
        while True:
            # Block until theme changes
            theme = await mon.async_get()

            # Themes have space-delimited attributes, one of which will be light or dark.
            parts = theme.split(" ")
            if "dark" in parts:
                # name = "GitHub Dark Default"
                name = "GitHub Dark Dimmed"
                # name = "GitHub Dark High Contrast"
                preset = await iterm2.ColorPreset.async_get(connection, name)
            else:
                name = "GitHub Light Default"
                preset = await iterm2.ColorPreset.async_get(connection, name)

            # Update the list of all profiles and iterate over them.
            profiles = await iterm2.PartialProfile.async_query(connection)
            for partial in profiles:
                # Fetch the full profile and then set the color preset in it.
                profile = await partial.async_get_full_profile()
                await profile.async_set_color_preset(preset)

iterm2.run_forever(main)
```
