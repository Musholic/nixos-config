# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, pkgs-distroav, ... }:
let
  impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
      "${impermanence}/nixos.nix"
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.kernel.sysctl."kernel.sysrq" = 1;

  boot = {
    kernelParams = [ "i915.force_probe=7d55" ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        enable = true;
        mirroredBoots = [
          {
            path = "/boot";
            efiSysMountPoint = "/boot/efi";
            efiBootloaderId = "NixOS-Stream";
            devices = [
              "/dev/disk/by-uuid/CE99-F9B3"
            ];
          }
        ];

        device = "nodev";
        efiSupport = true;
      };
    };
  };
  networking.hostName = "nixos-musholic-stream"; # Define your hostname.

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     useXkbConfig = true; # use xkb.options in tty.
   };

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.wayland.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "fr";
  services.xserver.xkb.options = "caps:escape";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.hyprland.withUWSM  = true;

  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    NIXOS_OZONE_WL = "1"; # Force intel-media-driver
  }; 

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = true;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    #package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      #  sync.enable = true;
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.hedgedoc = {
    enable = true;
    settings.port = 8001;
    settings.domain = "nixos-musholic-stream.home:8001";
    settings.host = "192.168.1.37";
    settings.allowFreeURL = true;
    settings.allowAnonymousEdits = true;
  };

  services.openvpn.servers = {
    streamVPN    = { config = '' config /root/nixos/openvpn/openvpn.ovpn ''; };
  };


  # Allow unfree license
  nixpkgs.config.allowUnfree = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.musholic = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
      rofi-power-menu
      google-chrome
      polybar
      maim # for screenshots
    ];
    shell = pkgs.zsh;
  };

  home-manager.backupFileExtension = "hm-backup";
  home-manager.users.musholic = { pkgs, ... }: {
   imports = [ "${impermanence}/home-manager.nix" ];
   home.sessionVariables = {
      DISK = "/disk";
    }; 

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "24.11";

    home.persistence."/nix/conf/home" = {
      files = with pkgs; let
        listFilesRecursive = dir: acc: lib.flatten (lib.mapAttrsToList
          (k: v: if k == ".nolink" then []
          else if ! builtins.pathExists  (dir + "/${acc}${k}/.nolink") then
          acc + k
          else
          listFilesRecursive dir (acc + k + "/"))
          (builtins.readDir ( dir + "/${acc}")));
  
        in listFilesRecursive ./home "";
    };
    home.file = {
      ".vim/bundle/Vundle.vim".source = builtins.fetchGit  "https://github.com/VundleVim/Vundle.vim.git";
      "git/sys/zgen".source = builtins.fetchGit "https://github.com/tarjoilija/zgen.git";
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    programs.rofi = {
      enable=true;
      package = pkgs.rofi-wayland;
      theme = "Adapta-Nokto";
    };

    programs.waybar = {
      enable=true;
      systemd.enable = true;
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs-distroav.obs-studio-plugins; [
        distroav
      ];
    };

  };

  # programs.firefox.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableGlobalCompInit = false;
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
    nerdfonts
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim-full
    wget
    git
    numlockx
    autorandr
    xfce.xfce4-power-manager
    pasystray
    blueman
    sxhkd
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
    nix-search
    manix
    moreutils
  ];

  environment.persistence."/nix/persist/system" = {
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.gpm.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

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

