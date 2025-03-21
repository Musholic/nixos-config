{lib, ...}: {
  specialisation = {
    backup.configuration = {
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
