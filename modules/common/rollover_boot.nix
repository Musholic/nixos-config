{
  lib,
  config,
  ...
}: {
  boot.initrd.postDeviceCommands = lib.mkForce ''
    mkdir /btrfs_tmp
    mount /dev/disk/by-label/${config.disk.rootDiskLabel} /btrfs_tmp
    # If the file NO_ROLLOVER exists, skip rollover
    if [[ -e /btrfs_tmp/${config.disk.rootDir}/root/NO_ROLLOVER ]]; then
      echo "NO_ROLLOVER exists, skipping rollover"
    else
      if [[ -e /btrfs_tmp/${config.disk.rootDir}/root ]]; then
        mkdir -p /btrfs_tmp/${config.disk.rootDir}/old_roots
        timestamp=$(date +"%Y%m%d_%H%M%S")
        echo "Rolling over root to old_roots/$timestamp"
        mv /btrfs_tmp/${config.disk.rootDir}/root "/btrfs_tmp/${config.disk.rootDir}/old_roots/$timestamp"
      fi

      #for i in $(find /btrfs_tmp/${config.disk.rootDir}/old_roots/ -maxdepth 1 -mtime +30); do
      #    btrfs subvolume delete -R "$i"
      #done

      btrfs subvolume create /btrfs_tmp/${config.disk.rootDir}/root
    fi
    umount /btrfs_tmp
  '';
}
