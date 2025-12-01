{pkgs, ...}: {
  imports = [
    ../common
  ];

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  hardware.graphics = {
    enable = true;
    # extraPackages = with pkgs; [nvidia-vaapi-driver];
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  security.pam.services.sddm.enableGnomeKeyring = true;
  security.rtkit.enable = true;

  services = {
    # System services
    fwupd.enable = true;
    thermald.enable = true;
    gpm.enable = true;
    upower.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    dbus.enable = true;
    tumbler.enable = true;

    # Display services
    xserver = {
      enable = true;
      xkb = {
        layout = "fr";
        options = "caps:escape";
      };
    };
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    blueman.enable = true;
    gnome = {
      gnome-keyring.enable = true;
      gcr-ssh-agent.enable = true;
    };

    # Audio services
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };
    flatpak.enable = true;
  };

  programs = {
    dconf.enable = true;
    xfconf.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
    thunar = {
      enable = true;
    };
    seahorse.enable = true;
    fuse.userAllowOther = true;
    steam.enable = true;
  };

  fonts.packages = with pkgs; [
    # Default
    dejavu_fonts
    freefont_ttf
    gyre-fonts # TrueType substitutes for standard PostScript fonts
    liberation_ttf
    unifont
    noto-fonts-color-emoji
    # Custom
    noto-fonts
    nerd-fonts.terminess-ttf
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  # Add desktop-specific packages to the base list
  environment.systemPackages = with pkgs; [
    numlockx
    autorandr
    xfce.xfce4-power-manager
    pasystray
    blueman
    kitty
    ntfs3g
    networkmanagerapplet
    xfce.xfce4-notifyd
    pavucontrol
    xsel
    ranger
    feh
  ];
  environment.persistence."/nix/persist/system" = {
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/flatpak"
    ];
  };
}
