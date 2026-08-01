{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    # HM 26.05: defaults flipped to false; keep explicit to silence stateVersion warnings.
    withRuby = false;
    withPython3 = false;
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
