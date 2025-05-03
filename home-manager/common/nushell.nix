{pkgs, ...}: {
  programs.nushell = {
    enable = true;
    shellAliases = {
      # General aliases
      wh = "view source";
      du1 = "du -h -d 1";
      tree0 = "tree -ah --du";
      tree0p = "tree -ahpug --du";
      tree1 = "tree -ah --du -L 2";

      # Network aliases
      myip = "curl ipecho.net/plain ; echo";
      myip4 = "curl -4 ipecho.net/plain ; echo";

      # Git aliases
      gA = "git add -A";
      glp = "git log -p --color-words";
      gd = "git diff --color-words --find-renames";
      gdc = "git diff --cached --color-words --find-renames";
      gff = "git flow feature";
      gfb = "git flow bugfix";
      gfr = "git flow release";
      gfh = "git flow hotfix";

      # Editor aliases
      z = "zed -n";
      v = "zed-replace";
      f = "feh -.";

      # Directory aliases
      cdnolink = "cd (readlink -f .)";
      o = "xdg-open";
      p = "pgrep -a";
      aider = "LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH aider";
      l = "ls -la --short-names";

      # Sudo alias
      s = "sudo -E";
      man = "man";

      # NixOS specific aliases
      nfupdate = "nix flake update --commit-lock-file --flake /nix/conf";
      nupdate = "nixos-rebuild --use-remote-sudo -I nixos-config=/nix/conf --flake /nix/conf?submodules=1 switch";
      nopts-update = "optinix -- update";
    };

    # Custom functions
    # TODO: put in an external file
    extraConfig = builtins.readFile ./nushell_config.nu;
  };

  xdg.configFile = {
    "nushell/plugins/nu_plugin_skim" = {
      source = "${pkgs.nushellPlugins.skim}/bin/nu_plugin_skim";
      executable = true;
    };
    "nushell/git-aliases.nu" = {
      source = "${pkgs.fetchFromGitHub {
        owner = "KamilKleina";
        repo = "git-aliases.nu";
        rev = "main";
        sha256 = "sha256-h4cQwjiUMaHYDVgyaOAHC7sQJZNyyDy8kKP9/YoUy48=";
      }}/git-aliases.nu";
    };
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
    };
  };
}
