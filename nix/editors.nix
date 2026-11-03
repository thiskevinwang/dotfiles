{ pkgs, inputs, ... }:
let
  sharedPlugins = with pkgs.vimPlugins; [
    vim-gitgutter vim-airline vim-airline-themes ctrlp-vim vim-go typescript-vim
    vim-jsx-typescript vim-javascript vim-hcl vim-nix vim-toml nerdcommenter coc-nvim
    (pkgs.vimUtils.buildVimPlugin {
      pname = "vim-jsx"; version = "locked"; src = inputs.vim-jsx;
    })
    (pkgs.vimUtils.buildVimPlugin {
      pname = "vim-simple-notifications"; version = "locked";
      src = inputs.vim-simple-notifications;
    })
  ];
  neovimPlugins = with pkgs.vimPlugins; [
    github-nvim-theme nvim-web-devicons nvim-tree-lua diffview-nvim toggleterm-nvim
    plenary-nvim telescope-nvim nvim-notify auto-dark-mode-nvim
  ];
  pluginFiles = directory: plugins: builtins.listToAttrs (map (plugin: {
    name = "${directory}/${pkgs.lib.getName plugin}";
    value.source = plugin;
  }) plugins);
in {
  home.file = {
    ".vimrc".text = ''
      let g:dotfiles_nix_plugins = 1
      packloadall
      source ${../vimrc}
    '';
    ".config/nvim/init.vim".text = ''
      set runtimepath^=~/.vim runtimepath+=~/.vim/after
      let &packpath=&runtimepath
      source ~/.vimrc
    '';
  } // pluginFiles ".vim/pack/dotfiles/start" sharedPlugins
    // pluginFiles ".local/share/nvim/site/pack/dotfiles/start" neovimPlugins;
}
