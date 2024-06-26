{ config, pkgs, lib, ... }:
let
  secrets = import ../../../secrets.nix;
in
{
  # This is required so that pod can reach the API server (running on port 6443 by default)
  networking.firewall.allowedTCPPorts = [ 6443 ];
  services.k3s = {
    enable = true;
    package = pkgs.unstable.k3s;
    role = "agent";
    serverAddr = lib.mkDefault "https://k3s-0:6443";
    token = lib.mkDefault secrets.k3s_node_token;
    extraFlags = "--node-label \"k3s-upgrade=false\""; # Optionally add additional args to k3s
  };

  environment.systemPackages = [ pkgs.unstable.k3s ];
}
