{lib, ...}:
with lib; {
  options.disk = {
    rootDiskLabel = mkOption {
      type = types.str;
      description = "Label of the root disk used for boot containing /nixos_roots and /nix";
    };
  };
}
