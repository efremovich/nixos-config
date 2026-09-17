{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "2fa";
  version = "unstable-2026-08-05";

  src = fetchFromGitHub {
    owner = "rsc";
    repo = "2fa";
    rev = "3b314a29f85f448059c2facbc9c77cada5e6f806";
    sha256 = "sha256-ESC5mnz9dhfPAiqKTtqhcjCKF0bh3Ob0haK7xVhxU9k=";
  };

  vendorHash = null;

  # vendor/ upstream не содержит modules.txt, из-за чего go считает vendoring
  # несогласованным — генерируем его заново.
  postPatch = ''
    cat > vendor/modules.txt <<'MODTXT'
    # github.com/atotto/clipboard v0.1.2
    ## explicit
    github.com/atotto/clipboard
    MODTXT
  '';

  meta = {
    description = "Command-line TOTP (RFC 6238) two-factor authentication codes";
    homepage = "https://rsc.io/2fa";
    license = lib.licenses.bsd3;
    mainProgram = "2fa";
  };
}
