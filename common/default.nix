{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./disk_config.nix
    ./rollover_boot.nix
  ];
}
