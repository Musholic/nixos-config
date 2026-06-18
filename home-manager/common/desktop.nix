{
  pkgs,
  pkgs-unstable,
  deferred,
  inputs,
  config,
  ...
}: {
  imports = [
    ../common
    inputs.nixcord.homeModules.nixcord
    inputs.dms.homeModules.dank-material-shell
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
      ".cache/JetBrains"
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
    chromium = {
      enable = true;
      package = pkgs.brave;
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
    dank-material-shell = {
      enable = true;
      systemd = {
        enable = true; # Systemd service for auto-start
        restartIfChanged = true; # Auto-restart dms.service when dank-material-shell changes
      };

      session = {
        isLightMode = false;
      };

      # Core features
      enableSystemMonitoring = true; # System monitoring widgets (dgop)
      enableVPN = true; # VPN management widget
      enableDynamicTheming = true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = true; # Audio visualizer (cava)
      enableCalendarEvents = true; # Calendar integration (khal)
      enableClipboardPaste = true; # Pasting items from the clipboard (wtype)
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
    gtk4.theme = config.gtk.theme;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  # Packages to install
  home.packages = with pkgs; [
    rofi-power-menu
    polybar
    zathura
    feh
    sshuttle
    pkgs-unstable.zed-editor
    # Alias for zed-editor
    (pkgs.writeShellScriptBin "zed" ''
      export GITHUB_TOKEN=$(gh auth token)
      exec ${lib.getExe pkgs-unstable.zed-editor} "$@"
    '')
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
