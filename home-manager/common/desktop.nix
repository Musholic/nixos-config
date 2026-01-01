{
  pkgs,
  pkgs-zed,
  config,
  ...
}: {
  imports = [
    ../common
  ];

  home.persistence."/nix/persist/home" = {
    files = [
      # Directory mount seems to cause issues for steam and flatpak for unkown reasons
      ".local/share/flatpak"
      ".var/app"
    ];
    directories = [
      ".local/share/zed"
      ".config/google-chrome"
      ".local/share/Steam"
      ".local/share/keyrings"
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
  home.packages = with pkgs;
    [
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

      clipse
      wl-clipboard
      grim
      slurp

      pulseaudio # For pactl utilities

      inkscape
      discord
    ]
    ++ (pkgs.lib.optionals (!config.boot.isRamBoot) [
      pkgs.jetbrains.idea-community-bin
      pkgs.wineWowPackages.stable
    ]);

  home.pointerCursor = {
    name = "Catppuccin Mocha Sapphire";
    gtk.enable = true;
    size = 24;
    package = pkgs.catppuccin-cursors.mochaSapphire;
  };
}
