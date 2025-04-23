{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  nix.settings = {
    trusted-users = ["musholic"];

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://zed-industries.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "zed-industries.cachix.org-1:QW3RoXK0Lm4ycmU5/3bmYRd3MLf4RbTGPqRulGlX5W0="
    ];
  };
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
      inherit pkgs-unstable;
    };
    users.musholic = {...}: {
      imports = [../../home-manager/home.nix];
    };
  };
}
