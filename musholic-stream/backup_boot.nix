{lib, ...}: {
  specialisation = {
    backup.configuration = {
      boot.initrd.postDeviceCommands = lib.mkForce ''
        mkdir -p /mnt-root/disk0
        mount -t ext4 /dev/disk/by-label/nixos_stream /mnt-root/disk0
        mkdir -p /mnt-root/disk0/nixos_roots/backup
      '';

      fileSystems."/" =
        lib.mkForce
        {
          device = "/disk0/nixos_roots/backup";
          fsType = "none";
          options = ["bind"];
        };
    };
  };
}
