{ pkgs, ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      status.disabled = false;
      username = {
        # format = "[$user]($style)";
        # show_always = true;
      };
      hostname = {
        ssh_only = true;
        disabled = false;
        ssh_symbol = "@";
      };
      kubernetes = {
        disabled = false;
        format = "on [ t $cluster( \\( $namespace\\))]($style) ";
      };
      ocaml.disabled = true;
      perl.disabled = true;
      cmd_duration = {
        format = "took [$duration]($style) ";
      };

      directory = {
        format = "[$path]($style)( [$read_only]($read_only_style)) ";
      };

      # Cloud
      gcloud = {
        format = "on [$symbol($project)]($style) ";
      };

      # Icon changes only \/
      aws.symbol = "  ";
      conda.symbol = " ";
      dart.symbol = " ";
      directory.read_only = " ";
      docker_context.symbol = " ";
      elixir.symbol = " ";
      elm.symbol = " ";
      gcloud.symbol = " ";
      git_branch.symbol = " ";
      golang.symbol = " ";
      hg_branch.symbol = " ";
      java.symbol = " ";
      julia.symbol = " ";
      memory_usage.symbol = " ";
      nim.symbol = " ";
      nodejs.symbol = " ";
      package.symbol = " ";
      perl.symbol = " ";
      php.symbol = " ";
      python.symbol = " ";
      ruby.symbol = " ";
      rust.symbol = " ";
      scala.symbol = " ";
      shlvl.symbol = "";
      swift.symbol = "ﯣ ";
      terraform.symbol = "行";
    };
  };
}
