{ inputs, user, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    # Prefer the system location; migrate once before switch:
    #   sudo install -d -m 0700 /var/lib/sops-nix
    #   sudo cp ~/.config/sops/age/keys.txt /var/lib/sops-nix/key.txt
    #   sudo chmod 400 /var/lib/sops-nix/key.txt
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets = {
      tfs_pat = {
        owner = user;
        mode = "0400";
      };
      anthropic_api_key = {
        owner = user;
        mode = "0400";
      };
      waybar_ssh_host = {
        owner = user;
        mode = "0400";
      };
      waybar_ssh_user = {
        owner = user;
        mode = "0400";
      };
      waybar_ssh_port = {
        owner = user;
        mode = "0400";
      };
      waybar_proxy_port = {
        owner = user;
        mode = "0400";
      };
      waybar_ssh_key_file = {
        owner = user;
        mode = "0400";
      };
      waybar_nats_url = {
        owner = user;
        mode = "0400";
      };
      waybar_nats_creds_file = {
        owner = user;
        mode = "0400";
      };

    };
  };
}
