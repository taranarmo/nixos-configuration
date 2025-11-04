{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    extraConfig = ''
      set encoding=utf-8
      set nocompatible
      set ignorecase
      set smartcase
      set number
      filetype off

      set foldmethod=syntax
      set nofoldenable
      set foldlevel=2

      filetype plugin indent on
      " show existing tab with 4 spaces width
      set tabstop=4
      " when indenting with '>', use 4 spaces width
      set shiftwidth=4
      " On pressing tab, insert 4 spaces
      set expandtab
      syntax on

      let g:markdown_folding = 1

      let g:python_highlight_all = 1

      let g:tex_flavor = 'latex'
      let g:latex_to_unicode_auto = 1

      let g:slime_target = "tmux"
      let g:slime_python_ipython = 1

      autocmd FileType sql setlocal shiftwidth=2 tabstop=2
    '';
    extraPackages = with pkgs; [
      # LSP servers
      sqls
      terraform-ls
      nixd
      python3Packages.jedi-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      julia-vim
      #YouCompleteMe
      #ncm2 # completion
      #ncm2-syntax
      #ncm2-path
      #nvim-cmp
      #cmp-nvim-lsp
      nvim-lspconfig
      coq_nvim
      nvim-treesitter.withAllGrammars
      vim-easymotion
      supertab
      vimtex
      vim-better-whitespace
      nerdtree
      vim-abolish
      vim-commentary
      vim-dispatch
      vim-fugitive
      vim-surround
      vim-airline
      vim-airline-themes
      ale
      vim-slime
      tabular
      markdown-preview-nvim
      vim-wayland-clipboard
      python-syntax
      which-key-nvim
    ];
  };
}
