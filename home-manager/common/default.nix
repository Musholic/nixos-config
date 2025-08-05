{
  inputs,
  pkgs,
  pkgs-unstable,
  pkgs-optinix,
  pkgs-zed,
  ...
}: {
  imports = [
    ./nushell.nix
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
      # Directory mount seems to cause issues for steam and flatpak for unkown reasons
      ".local/share/flatpak"
      ".var/app"
    ];
    directories = [
      ".local/share/zed"
      ".local/share/direnv"
      ".config/google-chrome"
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
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      theme = "Adapta-Nokto";
    };
    waybar = {
      enable = true;
      systemd.enable = true;
    };
    zsh.enable = true;
    alacritty.enable = true;
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
  };

  services = {
    screen-locker = {
      enable = true;
      lockCmd = "hyprlock";
      xautolock.enable = false;
    };
    network-manager-applet.enable = true;
    blueman-applet.enable = true;
    gnome-keyring = {
      components = ["secrets" "pkcs11" "ssh"];
      enable = true;
    };
    mako.enable = true;
  };

  # Enable X session
  xsession.enable = true;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  home.file = {
    ".vim/bundle/Vundle.vim".source = inputs.vundle;
    "sys/zgen".source = inputs.zgen;
  };

  # Packages to install
  home.packages = with pkgs; [
    tree
    rofi-power-menu
    google-chrome
    polybar
    zathura
    feh
    sshuttle
    pkgs-zed
    kanshi
    wtype
    hyprlock
    nixd
    nil
    alejandra
    taskwarrior3
    taskwarrior-tui

    clipse
    wl-clipboard
    grim
    slurp

    pkgs-optinix
    ranger

    jetbrains.idea-community-bin
    wineWowPackages.stable
    unzip
    ripgrep

    pulseaudio # For pactl utilities

    pkgs-unstable.devenv
    rclone
  ];
  
  home.pointerCursor = {
    name = "Catppuccin Mocha Sapphire";
    gtk.enable = true;
    size = 24;
    package = pkgs.catppuccin-cursors.mochaSapphire;
  };
}
