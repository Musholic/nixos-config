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

  systemd.timers.pull-updates.timerConfig.Persistent = true;

  systemd.services.pull-updates = {
    description = "Pulls changes to system config";
    restartIfChanged = false;
    wants = ["network-online.target"];
    after = ["network-online.target"];
    onSuccess = ["rebuild.service"];
    startAt = "00:00";
    path = [pkgs.git pkgs.openssh pkgs.bash pkgs.curl];
    script = ''
      echo "Waiting for network connectivity to github.com..."
      timeout 60 bash -c 'until curl -s --head https://github.com >/dev/null 2>&1; do sleep 1; done'
      if [ $? -ne 0 ]; then
        echo "Failed to reach github.com within 60 seconds"
        exit 1
      fi
      git fetch
      nb_commits_to_pull=$(git rev-list --count HEAD..origin/master)

      if [ "$nb_commits_to_pull" -gt 0 ]; then
        git pull --rebase
        exit 0
      fi
      exit 1
    '';
    serviceConfig = {
      WorkingDirectory = "/nix/conf";
      Type = "oneshot";
    };
  };

  systemd.services.rebuild = {
    description = "Rebuilds and activates system config";
    restartIfChanged = false;
    path = [pkgs.nixos-rebuild pkgs.systemd pkgs.git];
    script = ''
      for dir in "/nix/conf";  do
        if ! git config --global --get-all safe.directory | grep -qFx "$dir"; then
          git config --global --add safe.directory "$dir"
        fi
      done
      nixos-rebuild --flake /nix/conf switch --accept-flake-config
      booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
      built="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"

      if [ "''${booted}" != "''${built}" ]; then
        echo "The system needs to reboot on up-to-date kernel"
      fi
    '';
    serviceConfig = {
      User = "root";
      Type = "oneshot";
    };
  };

  # Fix network manager wait online service not waiting for connection
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];
    };
  };

  networking = {
    networkmanager = {
      enable = true; # Easiest to use and most distros use this by default.
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

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
      "https://zed.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  users.mutableUsers = true; # Prevent accidental user/password deletion

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  virtualisation.docker = {
    enable = true;
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
      "/var/lib/nixos"
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
    htop
    fzf
    python3
    killall
    ruby
    gnumake
    gcc
    cmake
    pkg-config
    gnupg
    jq
    yq
    ncdu
    ack
    silver-searcher
    manix
    moreutils
    unison # To allow synchronizing files between computers
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

  system.stateVersion = "24.11";
}
