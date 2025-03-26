{
  lib,
  pkgs,
  ...
}: {
  # TODO: add option isRamBoot
  specialisation = {
    ram.configuration = {
      boot.initrd = {
        verbose = true;

        extraUtilsCommands = ''
          # Copy the 'nix' command and its dependencies
          copy_bin_and_libs ${pkgs.nix}/bin/nix
        '';
      };
      boot.initrd.postDeviceCommands = lib.mkForce ''
        mkdir -p /mnt-root/disk
        mkdir -p /mnt-root/ram
        mount -t ext4 /dev/disk/by-label/nixos_stream /disk
        mount --bind /disk/nix /nix
        mount -t tmpfs -o size=32G tmpfs /mnt-root/ram
        nix copy --no-check-sigs --substitute-on-destination --from /disk --to /mnt-root/ram /nix/store/d3ydrb42cgfcivx56vr7b4c55aj7mrqm-nixos-system-nixos-musholic-stream-24.11.20250321.ca8ec36
        umount /nix
        umount /disk
      '';

      fileSystems."/" = lib.mkForce {
        device = "/ram";
        fsType = "none";
        options = ["bind"];
      };
    };
  };
}
