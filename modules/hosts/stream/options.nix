{ lib, ... }:

{
  options = {
    musholic = {
      rootDiskLabel = lib.mkOption {
        type = lib.types.str;
        default = "nixos_stream";
        description = "Label of the root disk partition";
      };
    };
  };
}
