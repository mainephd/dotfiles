{ config, pkgs, lib, home-manager, ... }:
{
  imports = [
    ../common/darwin/defaults.nix
    ./homebrew.nix
    ../common/optional/fish.nix
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/src.github/dotfiles/hosts/work_laptop/default.nix";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
