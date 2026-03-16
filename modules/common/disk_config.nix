{lib, ...}:
with lib; {
  options.disk = {
    rootDiskLabel = mkOption {
      type = types.str;
      description = "Label of the btrfs partition used for nixos containing /root, /config, /persistent, ...";
    };
    rootDir = mkOption {
      type = types.str;
      description = "Directory containing the root of the btrfs subvolume";
      default = ".";
    };
  };
}
