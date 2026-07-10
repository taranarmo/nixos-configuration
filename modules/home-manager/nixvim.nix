{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    # viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    nixpkgs.config.allowUnfree = true;
    nixpkgs.source = pkgs.path;

    colorschemes.catppuccin.enable = true;

    diagnostic = {
      settings = {
        virtual_lines.current_line = true;
      };
    };

    # Basic options
    opts = {
      encoding = "utf-8";
      compatible = false;
      ignorecase = true;
      smartcase = true;
      number = true;
      foldmethod = "syntax";
      foldenable = false;
      foldlevel = 2;
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
    };

    # File type settings
    autoCmd = [
      {
        event = "FileType";
        pattern = "sql";
        command = "setlocal shiftwidth=2 tabstop=2";
      }
    ];

    # Global variables
    globals = {
      markdown_folding = 1;
      python_highlight_all = 1;
      tex_flavor = "latex";
      latex_to_unicode_auto = 1;
      slime_target = "tmux";
      slime_python_ipython = 1;
    };

    # Plugins
    plugins = {
      lualine.enable = true;
      fzf-lua.enable = true;
      fff = {
        enable = true;
        settings = {
          layout = {
            height = 0.8;
            width = 0.8;
            preview_position = "right";
          };
          frecency.enabled = true;
          history.enabled = true;
          max_results = 100;
        };
      };
      #ale.enable = true;
      #better-whitespace.enable = true;
      commentary.enable = true;
      #dispatch.enable = true;
      #easymotion.enable = true;
      fugitive.enable = true;
      markdown-preview.enable = true;
      #nerdtree.enable = true;
      vim-surround.enable = true;
      #supertab.enable = true;
      #tabular.enable = true;
      which-key.enable = true;
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          mapping = {
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };
          snippet.expand = "luasnip";
          sources = [
            #{ name = "copilot"; }
            { name = "nvim_lsp"; }
            { name = "async_path"; }
            { name = "buffer"; }
            { name = "luasnip"; }
          ];
        };
        filetype = {
          python = {
            sources = [
              {
                name = "nvim_lsp";
                priority = 1000;
              }
              # { name = "copilot"; priority = 900; }
              {
                name = "luasnip";
                priority = 800;
              }
              {
                name = "treesitter";
                priority = 700;
              }
              {
                name = "buffer";
                priority = 600;
              }
              {
                name = "calc";
                priority = 500;
              }
              {
                name = "async_path";
                priority = 400;
              }
            ];
          };
          sql = {
            sources = [
              {
                name = "vim-dadbod-completion";
                priority = 900;
              }
              {
                name = "nvim_lsp";
                priority = 900;
              }
              {
                name = "treesitter";
                priority = 700;
              }
              {
                name = "buffer";
                priority = 600;
              }
              {
                name = "async_path";
                priority = 500;
              }
              {
                name = "calc";
                priority = 400;
              }
              # { name = "copilot"; priority = 100; }
            ];
          };
          markdown = {
            sources = [
              {
                name = "pandoc";
                priority = 1100;
              }
              # { name = "copilot"; priority = 1000; }
              {
                name = "luasnip";
                priority = 900;
              }
              {
                name = "buffer";
                priority = 800;
              }
              {
                name = "spell";
                priority = 700;
              }
              {
                name = "emoji";
                priority = 600;
              }
              {
                name = "dictionary";
                priority = 500;
              }
              {
                name = "calc";
                priority = 400;
              }
              {
                name = "async_path";
                priority = 300;
              }
            ];
          };
          sh = {
            sources = [
              # { name = "copilot"; priority = 1000; }
              {
                name = "buffer";
                priority = 900;
              }
              {
                name = "treesitter";
                priority = 800;
              }
              {
                name = "async_path";
                priority = 700;
              }
              {
                name = "calc";
                priority = 600;
              }
            ];
          };
          tex = {
            sources = [
              {
                name = "latex_symbols";
                priority = 1000;
              }
              # { name = "copilot"; priority = 900; }
              {
                name = "luasnip";
                priority = 800;
              }
              {
                name = "buffer";
                priority = 700;
              }
              {
                name = "treesitter";
                priority = 600;
              }
              {
                name = "spell";
                priority = 500;
              }
              {
                name = "async_path";
                priority = 400;
              }
            ];
          };
        };
      };
      luasnip.enable = true;
      # copilot-lua = {
      #   enable = true;
      #   settings = {
      #     panel.enabled = false;
      #     suggestion.enabled = false;
      #   };
      # };
      # copilot-chat.enable = true;
      # jupyter related
      jupytext.enable = true;
      hydra.enable = true;
      notebook-navigator = {
        enable = true;
        settings = {
          activate_hydra_keys = "<leader>h";
          hydra_keys = {
            add_cell_after = "b";
            add_cell_before = "a";
            # comment = "c";
            move_down = "j";
            move_up = "k";
            merge_cell_above = "M";
            merge_cell_below = "J";
            run = "X";
            run_and_move = "x";
            split_cell = "s";
          };
        };
      };
      iron = { # default for notebook-navigator
        enable = true;
        settings = {
          keymaps = {
            interrupt = "<space>s<space>";
          };
        };
      };
      # molten.enable = true; # doesn't respect current python environment

      vim-dadbod.enable = true;
      vim-dadbod-completion.enable = true;
      vim-dadbod-ui.enable = true;

      # LSP configuration
      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          terraformls = {
            enable = true;
            extraOptions = {
              on_attach.__raw = ''
                function(client, bufnr)
                  client.server_capabilities.signatureHelpProvider = false
                  client.server_capabilities.semanticTokensProvider = nil
                end
              '';
            };
          };
          nixd.enable = true;
          jedi_language_server.enable = true;
          pyright.enable = true;
          yamlls.enable = true;
          jsonls.enable = true;
          taplo.enable = true;
        };

      };

      # Treesitter configuration
      # treesitter = {
      #   enable = true;
      #   settings.ensure_installed = "all";
      # };

      # CoQ completion
      #coq = {
      #  enable = true;
      #  installArtifacts = true;
      #};
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = ":FFFFind<CR>";
        options.silent = true;
      }
    ];

    # Extra packages
    extraPackages = with pkgs; [
      sqlfluff
      nixd
      python3Packages.jedi-language-server
    ];
  };
}
