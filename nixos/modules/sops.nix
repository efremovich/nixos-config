{
  inputs,
  lib,
  user,
  ...
}:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    # Prefer the system location; migrate once before switch:
    #   sudo install -d -m 0700 /var/lib/sops-nix
    #   sudo cp ~/.config/sops/age/keys.txt /var/lib/sops-nix/key.txt
    #   sudo chmod 400 /var/lib/sops-nix/key.txt
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets = lib.genAttrs [
      "tfs_pat"
      "anthropic_api_key"
      "waybar_ssh_host"
      "waybar_ssh_user"
      "waybar_ssh_port"
      "waybar_proxy_port"
      "waybar_ssh_key_file"
      "waybar_nats_url"
      "waybar_nats_creds_file"
      "rdp_holding_name"
      "rdp_holding_host"
      "rdp_holding_user"
      "rdp_holding_password"
      "rdp_holding_buh_name"
      "rdp_holding_buh_host"
      "rdp_holding_buh_user"
      "rdp_holding_buh_password"
      "rdp_autokart_name"
      "rdp_autokart_host"
      "rdp_autokart_user"
      "rdp_autokart_password"
    ] (_: {
      owner = user;
      mode = "0400";
    });
  };
}
