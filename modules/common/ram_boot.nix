{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./ram_boot_options.nix
  ];

  specialisation = {
    ram.configuration = {
      boot.isRamBoot = true;
      boot.initrd = {
        verbose = true;

        # Add zram to the loaded kernel modules by initrd
        kernelModules = ["zram"];

        supportedFilesystems = ["btrfs"];
      };

      boot.initrd.postDeviceCommands = lib.mkForce ''
        # First mount disk on /disk
        mkdir -p /disk
        mount -o ro /dev/disk/by-label/nixos /disk

        # Create and mount /ram
        mkdir -p /ram
        echo 64G > /sys/block/zram0/disksize
        echo lz4 > /sys/block/zram0/comp_algorithm
        /disk/${pkgs.e2fsprogs}/bin/mkfs.ext4 /dev/zram0
        mount /dev/zram0 /ram

        echo "Press enter to begin copying nix store to ram"
        read
        /disk/${pkgs.nix}/bin/nix --offline --extra-experimental-features nix-command --extra-experimental-features read-only-local-store copy --no-check-sigs --substitute-on-destination --from /disk?read-only=1 --to /ram $stage2Init

        echo "Press enter to continue with the rsync..."
        read
        /disk/${pkgs.rsync}/bin/rsync -aP /disk/config/ /ram/nix/conf
        # Exclude some big directories to speed up
        /disk/${pkgs.rsync}/bin/rsync -aP --exclude home/.config/google-chrome --exclude home/.config/discord --exclude home/git --exclude home/.local /disk/persistent/ /ram/nix/persist

        echo "Unmounting disk and ram..."
        umount /disk
        umount /ram

        echo "Rsync complete, press enter to continue..."
        read
      '';

      fileSystems."/" = {
        device = "/dev/zram0";
        fsType = "ext4";
      };
    };
  };
}
