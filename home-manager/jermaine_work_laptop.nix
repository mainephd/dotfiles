{ inputs, lib, pkgs, config, outputs, ... }:
let
  secrets = import ../secrets.nix;
in
{
  imports = [
    ./common/global
    ./common/features/dev
    ./common/features/kubernetes
  ];

  home = {
    username = lib.mkDefault secrets.work_username;
    homeDirectory = lib.mkDefault "/Users/${config.home.username}";
    stateVersion = lib.mkDefault "24.11";
    sessionPath = [ "$HOME/.local/bin" "$HOME/go/bin" ];
  };

  home.packages = with pkgs; [
    azure-cli
    cloudfoundry-cli
    jwt-cli
    rancher
    terminal-notifier # send notifications to macOS notification center
    terraform
    vault
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        extraOptions = {
          AddKeysToAgent = "yes";
          UseKeychain = "yes";
          IdentityFile = "~/.ssh/id_ed25519";
        };
      };
    };
  };

  programs.git = {
    userName = secrets.work_git_username;
    userEmail = secrets.work_email;
    extraConfig = {
      init.defaultBranch = "main";
    };
    includes = [
      {
        condition = "gitdir:~/src.github/";
        contents = {
          user = {
            name = "mainephd";
            email = "jermaine_a_davis@homedepot.com";
          };
        };
      }
    ];
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      prompt = "enabled";
      prefer_editor_prompt = "disabled";
      aliases = {
        co = "pr checkout";
      };
    };
  };

  programs.fish = {
    shellAbbrs = {
      # override with machine-specific values
      rehome = lib.mkForce "home-manager switch --flake $HOME/src.github/dotfiles/.#jermaine@work-laptop";
      rebuild = lib.mkForce "darwin-rebuild switch --flake $HOME/src.github/dotfiles/.#work-laptop";
      tf = "terraform";
    };

    shellInit = ''
      set --export NODE_EXTRA_CA_CERTS ${secrets.work_certpath}
      set --export SSL_CERT_FILE ${secrets.work_certpath}
      set --export REQUESTS_CA_BUNDLE ${secrets.work_certpath}
      set --export NIX_SSL_CERT_FILE ${secrets.work_certpath}
      set --export GIT_SSL_CAINFO ${secrets.work_certpath}
      set --export CURL_CA_BUNDLE ${secrets.work_certpath}
      set --export PIP_CERT ${secrets.work_certdir}
    '';

    loginShellInit = ''for p in (string split " " $NIX_PROFILES); fish_add_path --prepend --move $p/bin; end'';

    interactiveShellInit =
      # load brew environment
      ''
      eval (/opt/homebrew/bin/brew shellenv)
      '' +
      # handle gcloud CLI
      ''
      source ~/google-cloud-sdk/path.fish.inc
      '' +
      # add custom localized paths
      ''
      fish_add_path $HOME/.rd/bin
      fish_add_path $HOME/go/bin
      fish_add_path $HOME/.local/bin
      '';
  };

  # starship kubernetes module override
  programs.starship.settings.kubernetes = {
    format = "on [ t $cluster( \\( $namespace\\))]($style) ";
    disabled = false;
  };
}
