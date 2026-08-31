# Ghostty title with tmux and Codex

Research date: 2026-08-29

## Result

Use the active tmux pane title as the complete outer-terminal title:

```tmux
set -g set-titles on
set -g set-titles-string '#T'
```

Then configure Codex to put its thread title in that pane title. Run `/title` in Codex and select `thread-title`. Or use this equivalent Codex configuration:

```toml
[tui]
terminal_title = ["activity", "thread-title"]
```

For the shortest title, use only `thread-title`. Use `/rename` to set a clear session name.

Expected path:

```text
Codex thread title -> OSC 0 -> tmux pane title (#T) -> Ghostty window/tab title
```

## Cause of the current long title

The local tmux configuration enables `set-titles`, but does not set `set-titles-string`: [tmux.conf](../../tmux.conf). The active tmux server therefore uses this default format:

```text
#S:#I:#W - "#T" #{session_alerts}
```

The observed value was:

```text
0:0:codex - "[ ! ] Action Required | dotfiles"
```

Thus, tmux adds the session, window index, window name, quotes, and alerts. `#T` alone removes this extra text. The official tmux manual source confirms that `set-titles-string` controls the client terminal title and expands formats. It also defines the pane title as application-set title text: [tmux title options](https://github.com/tmux/tmux/blob/master/tmux.1#L5463-L5483), [tmux names and titles](https://github.com/tmux/tmux/blob/master/tmux.1#L7753-L7812).

Codex 0.151.0 already supplies the useful part. Its source defines `thread-title` as the current thread title, or the thread identifier when unnamed. `/title` is the interactive picker for these fields: [Codex title picker source](https://github.com/openai/codex/blob/main/codex-rs/tui/src/bottom_pane/title_setup.rs#L29-L52). The default Codex title contains only `activity` and `project-name`, so the thread title must be selected: [Codex default title source](https://github.com/openai/codex/blob/main/codex-rs/tui/src/chatwidget/status_surfaces.rs#L22-L24).

## Ghostty limits

The local Ghostty configuration changes the title font only: [ghostty/config](../../ghostty/config). It does not force a static `title`.

Ghostty accepts title escape sequences unless its `title` option is set. That option forces one static title and ignores application title updates, so it is not suitable here: [Ghostty `title` reference](https://ghostty.org/docs/config/reference#title).

Ghostty has no documented option to disable title ellipsis or set the macOS title text width. The default macOS `transparent` titlebar is the native titlebar with a transparent background. Therefore, macOS can clip visible text when titlebar space is small. This is an inference from the official titlebar options: [Ghostty `macos-titlebar-style` reference](https://ghostty.org/docs/config/reference#macos-titlebar-style).

Codex also limits each rendered `thread-title` segment to 48 grapheme clusters and the complete emitted title to 240 characters: [Codex title rendering](https://github.com/openai/codex/blob/main/codex-rs/tui/src/chatwidget/status_surfaces.rs#L779-L802), [Codex OSC title writer](https://github.com/openai/codex/blob/main/codex-rs/tui/src/terminal_title.rs#L20-L52). A shorter tmux format improves the available space, but cannot remove these application and macOS limits.

## Equivalent display inside tmux

If the macOS titlebar still clips the text, show the pane title on each tmux pane border:

```tmux
set -g pane-border-status top
set -g pane-border-format ' #{pane_title} '
```

The official tmux manual source defines both options and confirms that applications can set pane titles: [tmux pane-border options](https://github.com/tmux/tmux/blob/master/tmux.1#L5932-L5975), [tmux pane titles](https://github.com/tmux/tmux/blob/master/tmux.1#L7753-L7812).

This display is pane-local. It is useful when two Codex sessions share one tmux window.

## Recommended minimal configuration

```tmux
# tmux.conf
set -g set-titles on
set -g set-titles-string '#T'
```

```toml
# ~/.codex/config.toml
[tui]
terminal_title = ["activity", "thread-title"]
```

No Ghostty configuration change is required.
