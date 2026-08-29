{ config, pkgs, lib, ... }:

{
  # ------------------------------------------------------------------
  # tmux
  # ------------------------------------------------------------------
  programs.tmux = {
    enable = true;
    mouse = true;
    plugins = [ pkgs.tmuxPlugins.tmux-powerline ];
    extraConfig = ''
      set -g set-titles on

      # Dim inactive panes
      # set -g window-active-style 'fg=white,bg=black'

      # Pane borders use the terminal background; tmux has no alpha colors.
      set -g pane-border-style 'fg=#404040,bg=default'
      set -g pane-active-border-style 'fg=#ffffff,bg=default'
    '';
  };

  home.file.".config/tmux-powerline/themes/theme.sh".source = ../tmux-powerline/theme.sh;

  # ------------------------------------------------------------------
  # Ghostty
  # ------------------------------------------------------------------
  home.file.".config/ghostty/config".source = ../ghostty/config;
}
