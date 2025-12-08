{
  inputs,
  pkgs,
  pkgs-unstable,
  pkgs-optinix,
  ...
}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    ./nushell.nix
    ../../modules/common/ram_boot_options.nix
  ];
  home.stateVersion = "24.11";

  home.persistence."/nix/persist/home" = {
    allowOther = false;
    defaultDirectoryMethod = "symlink";
    files = [
      ".zsh_history"
      ".config/rclone/rclone.conf"
      ".config/nushell/history.txt"
      ".config/nushell/history.sqlite3"
    ];
    directories = [
      ".local/share/direnv"
      "git"
      ".ssh"
      ".local/share/taskwarrior-tui"
      ".task"
      ".zgen"
    ];
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 4";
      flake = "/nix/conf?submodules=1";
    };
    direnv = {
      enable = true;
      enableNushellIntegration = true;
    };
    nix-index = {
      enable = true;
      package = pkgs-unstable.nix-index;
    };
    mise = {
      enable = true;
      enableNushellIntegration = true;
      globalConfig = {
        settings = {
          # On Nix
          all_compile = false;
          idiomatic_version_file_enable_tools = [];
        };
      };
    };
  };

  home.file = {
    ".vim/bundle/Vundle.vim".source = inputs.vundle;
    "sys/zgen".source = inputs.zgen;
  };

  # Packages to install
  home.packages = with pkgs; [
    tree
    sshuttle
    nixd
    nil
    alejandra
    taskwarrior3
    taskwarrior-tui
    pkgs-optinix
    ranger
    unzip
    ripgrep
    pkgs-unstable.devenv
    rclone
    cachix
    tmux
    zsh
  ];
}
