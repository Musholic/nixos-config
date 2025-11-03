{
  lib,
  config,
  ...
}: {
  specialisation = {
    backup.configuration = {
      fileSystems."/".options = lib.mkForce ["subvol=backup_root" "compress=zstd" "noatime"];
    };
  };
}
