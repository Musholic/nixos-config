{lib, config, ...}: {
  specialisation = {
    rollover.configuration = {
      boot.initrd.postDeviceCommands = lib.mkForce ''
        mkdir -p /mnt-root/disk0
        mount -t ext4 /dev/disk/by-label/${config.disk.rootDiskLabel} /mnt-root/disk0
        # Create a timestamp for the old directory
        DATETIME=$(date +"%Y%m%d_%H%M%S")
        if [ -z "$DATETIME" ]; then
          echo "Error: Failed to generate timestamp"
          sleep 10s
        else
          # Move the current root to a timestamped directory
          mv /mnt-root/disk0/nixos_roots/current /mnt-root/disk0/nixos_roots/$DATETIME

          mkdir /mnt-root/disk0/nixos_roots/current
          # The system will create and boot to a new "current" root
        fi
      '';
    };
  };
}
