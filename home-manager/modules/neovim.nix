{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    # gopls в PATH внутри обёртки nvim (до Mason)
    extraPackages = with pkgs; [
      gopls
      delve
      golangci-lint
      gofumpt
      go-tools
      gomodifytags
      impl

    ];
  };
}
