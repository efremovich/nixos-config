{
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    # HM 26.05: не пишем свой init.lua в ~/.config/nvim, т.к. там git-конфиг LazyVim.
    # Провайдеры задаются через обёртку (--cmd 'lua dofile(...)'), а не через init.lua.
    sideloadInitLua = true;
    # HM 26.05: defaults flipped to false; keep explicit to silence stateVersion warnings.
    withRuby = false;
    withPython3 = false;
    # # gopls в PATH внутри обёртки nvim (до Mason)
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
