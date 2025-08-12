{ inputs, pkgs, ... }: {
  imports = [ inputs.LazyVim.homeManagerModules.default ];

  programs.lazyvim = {
    enable = true;
    # Add LSP servers and tools
    extraPackages = with pkgs; [
      rust-analyzer
      gopls
      nil
      nixfmt
      nodePackages.typescript-language-server
    ];

    # Add treesitter parsers
    treesitterParsers = with pkgs.tree-sitter-grammars; [
      tree-sitter-rust
      tree-sitter-go
      tree-sitter-typescript
      tree-sitter-tsx
    ];
  };
}
