# Full-featured LazyVim configuration example
# This demonstrates all available options and common use cases
{ pkgs, inputs, ... }: {
  # Import the LazyVim module
  imports = [ inputs.LazyVim.homeManagerModules.default ];

  programs.lazyvim = {
    enable = true;

    # LSP servers, formatters, linters, and tools
    extraPackages = with pkgs; [
      # LSP servers
      lua-language-server
      nil
      nixd
      pyright
      ruff
      clang
      yaml-language-server

      # go
      delve
      gofumpt
      golangci-lint
      gomodifytags
      gopls
      gotests
      gotools
      iferr
      impl

      # Formatters
      alejandra
      stylua
      ruff
      nixfmt

      # Tools
      ripgrep
      fd
      git
      lua5_1
      luarocks

      # Image preview tools
      viu
      chafa

      # SQLite for Snacks.picker frecency/history
      sqlite
      lua51Packages.luasql-sqlite3

      # Tools for Snacks.image rendering
      ghostscript # for PDF rendering
      tectonic # for LaTeX math expressions
      mermaid-cli # for Mermaid diagrams
    ];

    # Treesitter parsers for syntax highlighting
    treesitterParsers = with pkgs.tree-sitter-grammars; [
      tree-sitter-bash
      tree-sitter-css
      tree-sitter-html
      tree-sitter-javascript
      tree-sitter-json
      tree-sitter-latex
      tree-sitter-lua
      tree-sitter-markdown
      tree-sitter-nix
      tree-sitter-nu
      tree-sitter-python
      tree-sitter-regex
      tree-sitter-scss
      tree-sitter-toml
      tree-sitter-tsx
      tree-sitter-typescript
      tree-sitter-yaml
      tree-sitter-go
    ];

    # LazyVim configuration structure
    config = {
      options = ''
        vim.opt.relativenumber = true
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.expandtab = true
        vim.opt.wrap = false
        vim.opt.cursorline = true
        vim.opt.signcolumn = "yes"
        vim.opt.scrolloff = 8
        vim.opt.sidescrolloff = 8
      '';

      keymaps = "";

      autocmds = "";
    };

    # Plugin configurations
    plugins = {
      # Language-specific configurations
      languages = ''
        return {
          {
            "neovim/nvim-lspconfig",
            opts = {
              servers = {
                gopls = {
                  gofumpt = false,
                  settings = {
                    gopls = {
                      gofumpt = false,
                      codelenses = {
                        gc_details = false,
                        generate = true,
                        regenerate_cgo = true,
                        run_govulncheck = true,
                        test = true,
                        tidy = true,
                        upgrade_dependency = true,
                        vendor = true,
                      },
                      hints = {
                        assignVariableTypes = false,
                        compositeLiteralFields = false,
                        compositeLiteralTypes = false,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = false,
                        rangeVariableTypes = false,
                      },
                      analyses = {
                        nilness = true,
                        unusedparams = true,
                        unusedwrite = true,
                        useany = true,
                      },
                      usePlaceholders = false,
                      completeUnimported = true,
                      staticcheck = true,
                      directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
                      semanticTokens = true,
                    },
                  },
                },
              },
              setup = {
                gopls = function(_, opts)
                  -- workaround for gopls not supporting semanticTokensProvider
                  -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
                  LazyVim.lsp.on_attach(function(client, _)
                    if not client.server_capabilities.semanticTokensProvider then
                      local semantic = client.config.capabilities.textDocument.semanticTokens
                      client.server_capabilities.semanticTokensProvider = {
                        full = true,
                        legend = {
                          tokenTypes = semantic.tokenTypes,
                          tokenModifiers = semantic.tokenModifiers,
                        },
                        range = true,
                      }
                    end
                  end, "gopls")
                  -- end workaround
                end,
              },
            },
          },

          {
            "nvimtools/none-ls.nvim",
            optional = true,
            dependencies = {
              {
                "mason-org/mason.nvim",
                opts = { ensure_installed = { "gomodifytags", "impl" } },
              },
            },
            opts = function(_, opts)
              local nls = require("null-ls")
              opts.sources = vim.list_extend(opts.sources or {}, {
                nls.builtins.code_actions.gomodifytags,
                nls.builtins.code_actions.impl,
                nls.builtins.formatting.goimports,
                nls.builtins.formatting.gofmt,
              })
            end,
          },
          {
            "stevearc/conform.nvim",
            optional = true,
            opts = {
              formatters_by_ft = {
                go = { "goimports" },
              },
            },
          },
          {
            "nvim-neotest/neotest",
            optional = true,
            dependencies = {
              "fredrikaverpil/neotest-golang",
            },
            opts = {
              adapters = {
                ["neotest-golang"] = {
                  -- Here we can set options for neotest-golang, e.g.
                  -- go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
                  dap_go_enabled = true, -- requires leoluz/nvim-dap-go
                  runners = {
                    go = {
                      pre_run = function()
                        vim.env.GOLANG_PROTOBUF_REGISTRATION_CONFLICT = "warn"
                      end,
                    },
                  },
                },
              },
            },
          },
        }
      '';
    };
  };
}
