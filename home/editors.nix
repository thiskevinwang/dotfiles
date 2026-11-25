{ config, pkgs, lib, ... }:

{
  # ------------------------------------------------------------------
  # Vim / Neovim
  # ------------------------------------------------------------------
  # Existing ~/.vimrc is kept as-is and shared between vim and neovim, the
  # same way `install.sh` wired things up (`nvim`'s `init.vim` sources
  # `~/.vimrc`).
  home.file.".vimrc".source = ../vimrc;

  home.file.".config/nvim/init.vim".text = ''
    set runtimepath^=~/.vim runtimepath+=~/.vim/after
    let &packpath=&runtimepath
    source ~/.vimrc
  '';

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  # ------------------------------------------------------------------
  # VSCode
  # ------------------------------------------------------------------
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      bradlc.vscode-tailwindcss
      github.copilot
      github.copilot-chat
      golang.go
      # ms-vscode.vscode-typescript-next isn't packaged in nixpkgs; install
      # it manually via the Extensions view if needed.
    ];
  };

  # ------------------------------------------------------------------
  # Zed
  # ------------------------------------------------------------------
  home.file.".config/zed/settings.json".source = ../zed/settings.json;
  # Zed reads AGENTS.md from its config dir as AI agent context, mirroring
  # `sync_file "$SCRIPT_DIR/AGENTS.md" "$HOME/.config/zed/AGENTS.md"` in
  # the legacy install.sh.
  home.file.".config/zed/AGENTS.md".source = ../AGENTS.md;
}
