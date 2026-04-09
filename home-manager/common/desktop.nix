{
  pkgs,
  pkgs-zed,
  deferred,
  inputs,
  ...
}: {
  imports = [
    ../common
    inputs.nixcord.homeModules.nixcord
  ];

  home.persistence."/nix/persist/home" = {
    directories = [
      ".local/share/zed"
      ".config/BraveSoftware"
      ".config/google-chrome"
      ".config/JetBrains"
      ".local/share/keyrings"
      ".var/app"
      ".local/share/flatpak"
      ".config/Code"
    ];
  };

  home.persistence."/nix/cache/home" = {
    directories = [
      ".local/share/Steam"
      ".cache/BraveSoftware"
      ".wine"
      ".vscode"
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
    nixcord = {
      enable = true;
      discord.equicord.enable = true;
      discord.vencord.enable = false;
      config = {
        useQuickCss = true;
        plugins = {
          keywordNotify.enable = true;
          betterSettings.enable = true;
          readAllNotificationsButton.enable = true;
          showHiddenChannels.enable = true;
          whoReacted.enable = true;
          memberCount.enable = true;
          permissionsViewer.enable = true;
        };
      };
    };
    vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
      ];
      # TODO: add when stable: https://home-manager-options.extranix.com/?query=vscode.arg
      #argvSettings = {
      #  password-store = "gnome-libsecret";
      #};
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
    hyprshot
    qalculate-gtk

    pulseaudio # For pactl utilities

    (deferred inkscape)
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
