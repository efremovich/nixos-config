{ lib, ... }:
{
  nixpkgs.config.allowUnfree = true;
  # ВАЖНО: явный allowInsecurePredicate ПОЛНОСТЬЮ заменяет механизм
  # permittedInsecurePackages (check-meta.nix), поэтому все insecure-разрешения
  # держим в одном предикате здесь. И не в hosts/*: nixpkgs.config мержится
  # shallow — побеждает первый импортированный модуль.
  nixpkgs.config.allowInsecurePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      # libsoup 2 (EOL, неисправленные CVE) — 1С, FHS-окружение linux-app/apps/1c.nix.
      "libsoup"
      # broadcom-sta (wl) — Wi-Fi на lenovo; версия привязана к ядру,
      # поэтому по имени, а не по name-version.
      "broadcom-sta"
    ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  programs.nix-ld.enable = true;
}
