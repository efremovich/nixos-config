{ pkgs, ... }: {
  services.zapret = {
    enable = false;
    package = pkgs.zapret;

    udpSupport = true;
    udpPorts = [ "443" "50000:65535" ];

    whitelist = [ "youtube.com" ];

    params = [
      "--dpi-desync=fake"
      "--dpi-desync-fooling=badseq"
      "--dpi-desync-fake-tls=0x00000000"
      # "--dpi-desync-fake-tls=!"
      # "--dpi-desync-fake-tls-mod=rnd,rndsni,dupsid"

      # "--dpi-desync=fake,split2"
      # "--dpi-desync-ttl=7"
      # "--dpi-desync-fooling=badseq"
      # "--wssize 1:6"
      # "--dpi-desync-fake-tls=0x00000000"
      # "--dpi-desync-any-protocol"
      # "--dpi-desync-cutoff=128"
    ];
  };
}
