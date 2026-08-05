{
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    sideloadInitLua = true;
    withPython3 = false;
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

  xdg.dataFile."applications/nvim.desktop".text = ''
    [Desktop Entry]
    Name=Neovim wrapper
    GenericName=Text Editor
    Comment=Edit text files
    TryExec=alacritty
    Exec=alacritty -e nvim %F
    Icon=nvim
    Type=Application
    Terminal=false
    Categories=Utility;TextEditor;Development;
    MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
    Keywords=Text;Editor;
  '';
}
