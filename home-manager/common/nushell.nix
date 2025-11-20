{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: {
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
      nhupdate = "nh home switch /nix/conf?submodules=1";
      nupdate = "nh os switch /nix/conf?submodules=1 -- --accept-flake-config";
      nopts-update = "optinix update";
      specialize_to_streaming = "sudo /nix/var/nix/profiles/system/specialisation/streaming/bin/switch-to-configuration test";
      rollback_specialize = "sudo /nix/var/nix/profiles/system/bin/switch-to-configuration test";
      
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
      source = "${inputs.nushell-plugin-git-aliases}/git-aliases.nu";
    };
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
    package = pkgs-unstable.carapace;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
    };
  };
}
