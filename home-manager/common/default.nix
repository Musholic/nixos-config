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
    allowOther = true;
    files = [
      ".zsh_history"
      ".config/nushell/history.txt"
      ".config/nushell/history.sqlite3"
      # Directory mount seems to cause issues for steam and flatpak for unkown reasons
      ".local/share/flatpak"
      ".var/app"
    ];
    directories = [
      ".local/share/zed"
      ".config/google-chrome"
      "git"
      ".ssh"
      ".local/share/taskwarrior-tui"
      ".task"
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
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };
  };

  services = {
    screen-locker = {
      enable = true;
      lockCmd = "hyprlock";
      xautolock.enable = false;
    };
    ssh-agent.enable = true;
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
      package = pkgs.gnome.gnome-themes-extra;
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

    dotnet-sdk
    omnisharp-roslyn
    wineWowPackages.stable
    pkgs-unstable.spice
    pkgs-unstable.quickemu
    unzip
  ];
}
