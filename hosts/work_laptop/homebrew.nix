{ config, pkgs, ... }:

{
  #homebrew packages
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";
    brews = [
      "cask"
    ];
    taps = [
      "1password/tap"
      "cloudfoundry/tap"
      "hashicorp/tap"
      "homebrew/bundle"
      "universal-ctags/universal-ctags"
    ];
    casks = [
      "1password-cli"
      "codex"
      "font-hack-nerd-font"
    ];
  };
}
