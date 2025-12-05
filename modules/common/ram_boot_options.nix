{lib, ...}: {
  options.boot = {
    isRamBoot = lib.mkOption {
      type = lib.types.bool;
      description = "Whether the system is booting from RAM";
      default = false;
    };
  };
}
