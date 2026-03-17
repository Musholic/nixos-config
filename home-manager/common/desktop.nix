{
  pkgs,
  pkgs-zed,
  deferred,
  ...
}: {
  imports = [
    ../common
  ];

  home.persistence."/nix/persist/home" = {
    directories = [
      ".local/share/zed"
      ".config/BraveSoftware"
      ".config/google-chrome"
      ".local/share/keyrings"
      ".var/app"
      ".local/share/flatpak"
    ];
  };

  home.persistence."/nix/cache/home" = {
    directories = [
      ".local/share/Steam"
    ];
  };

  # Let Home Manager install and manage itself.
  programs = {
    rofi = {
      enable = true;
      theme = "Adapta-Nokto";
      modes = ["window" "run" "drun" "combi"];
      extraConfig = {
        combi-modi = "window,run,drun";
      };
    };
    waybar = {
      enable = true;
      systemd.enable = true;
    };
    alacritty.enable = true;
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

  # Packages to install
  home.packages = with pkgs; [
    rofi-power-menu
    (deferred google-chrome)
    (deferred brave)
    polybar
    zathura
    feh
    sshuttle
    pkgs-zed
    kanshi
    wtype
    hyprlock

    clipse
    wl-clipboard
    grim
    slurp

    pulseaudio # For pactl utilities

    (deferred inkscape)
    (deferred discord)
    (deferred pkgs.wineWow64Packages.stable)
    (deferred jetbrains.idea-oss)
  ];

  home.pointerCursor = {
    name = "Catppuccin Mocha Sapphire";
    gtk.enable = true;
    size = 24;
    package = pkgs.catppuccin-cursors.mochaSapphire;
  };
}
