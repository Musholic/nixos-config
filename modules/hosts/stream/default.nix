{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
    ./ram_boot.nix
    ./home.nix
    ./vm-specialization.nix
    ../../common
  ];

  disk.rootDiskLabel = "nixos_stream";
  
  systemd.services.pull-updates.serviceConfig.User = "musholic";

  boot = {
    kernelParams = ["i915.force_probe=7d55"];
    kernelPackages = pkgs.linuxKernel.packages.linux_6_14;
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
        useOSProber = true;
        default = "saved";
      };
    };
  };
  networking.hostName = "nixos-musholic-stream"; # Define your hostname.

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  services.hedgedoc = {
    enable = true;
    settings.port = 8001;
    settings.domain = "nixos-musholic-stream.home:8001";
    settings.host = "192.168.1.37";
    settings.allowFreeURL = true;
    settings.allowAnonymousEdits = true;
  };

  specialisation = {
    streaming.configuration = {
      services.openvpn.servers = {
        streamVPN = {config = ''config /root/nixos/openvpn/openvpn.ovpn '';};
      };
    };
  };
}
