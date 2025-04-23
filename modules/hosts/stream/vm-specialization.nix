{ ... }:

{
  # VM-specific configurations to test the flake with build-vm
  virtualisation.vmVariant = {
    musholic.rootDiskLabel = "nixos";
  };
}
