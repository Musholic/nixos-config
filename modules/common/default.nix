{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    ./disk_config.nix
    ./rollover_boot.nix
    ./backup_boot.nix
  ];

  # Allow unfree license
  nixpkgs.config.allowUnfree = true;

  boot.kernel.sysctl."kernel.sysrq" = 1;
  boot.kernelParams = ["kvm.ignore_msrs=1"];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking = {
    firewall.enable = false;
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  boot.loader.grub.configurationLimit = 10;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  nix.settings.auto-optimise-store = true;

  nix.settings = {
    trusted-users = ["musholic"];

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://zed-industries.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "zed-industries.cachix.org-1:QW3RoXK0Lm4ycmU5/3bmYRd3MLf4RbTGPqRulGlX5W0="
    ];
  };

  hardware.graphics = {
    enable = true;
    # extraPackages = with pkgs; [nvidia-vaapi-driver];
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  security.pam.services.sddm.enableGnomeKeyring = true;
  security.rtkit.enable = true;

  users.mutableUsers = true; # Prevent accidental user/password deletion

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
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
      xkb = {
        layout = "fr";
        options = "caps:escape";
      };
    };

    blueman.enable = true;
    gnome.gnome-keyring.enable = true;

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
    zsh = {
      enable = true;
      enableCompletion = true;
      enableGlobalCompInit = false;
    };

    file-roller = {
      enable = true;
    };
    seahorse.enable = true;
    fuse.userAllowOther = true;
    steam.enable = true;
  };

  virtualisation.docker = {
    enable = true;
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

  # Ensure we build our /nix/conf by default with nixos-rebuild
  environment.etc = {
    "nixos/flake.nix" = {
      source = "/nix/conf/flake.nix";
      mode = "symlink";
    };
  };

  environment.persistence."/nix/persist/system" = {
    hideMounts = true;
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/flatpak"
      "/etc/NetworkManager/system-connections"
      "/root/nixos"
    ];

    files = [
      "/etc/machine-id"
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  environment.systemPackages = with pkgs; [
    vim-full
    wget
    git
    tig
    numlockx
    autorandr
    xfce.xfce4-power-manager
    pasystray
    blueman
    htop
    fzf
    python3
    kitty
    ntfs3g
    networkmanagerapplet
    xfce.xfce4-notifyd
    killall
    pavucontrol
    ruby
    gnumake
    gcc
    cmake
    pkg-config
    gnupg
    xsel
    ranger
    jq
    yq
    ncdu
    ack
    silver-searcher
    feh
    manix
    moreutils
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
    ];
  };
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
