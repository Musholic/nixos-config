{
  inputs,
  pkgs,
  pkgs-unstable,
  pkgs-zed,
  pkgs-optinix,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  users.users.musholic = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker"];
    shell = pkgs.nushell;
    hashedPasswordFile = "/nix/persist/hashedPassword.txt";
    initialPassword = "tmpPass";
  };

  home-manager.backupFileExtension = "hm-backup";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      # Pass through the special package sets
      inherit pkgs-unstable pkgs-zed pkgs-optinix;
    };
    users.musholic = {...}: {
      imports = [../../../home-manager/home.nix];
    };
  };
}
