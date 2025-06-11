{
  config,
  pkgs,
  ...
}: let
  vfio_device_ids = [
    "10de:2782" # Nvidia card
    "10de:22bc" # Nvidia Audio Controller
  ];
in {
  boot = {
    kernelParams = ["intel_iommu=on" "iommu=pt" "iommu=1"];
    #kernelModules = ["kvm-intel"];

    extraModprobeConfig = ''
      options vfio-pci ids=${builtins.concatStringsSep "," vfio_device_ids}
      options vfio-pci disable_vga=1
    '';

    initrd.kernelModules = ["vfio" "vfio_iommu_type1" "vfio_pci"];
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    qemu.vhostUserPackages = with pkgs; [virtiofsd];
  };
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["musholic"];
}
