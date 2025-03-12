{
  description = "System config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-distroav.url = "git+file:///home/musholic/git/nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    vundle = {
      url = "github:VundleVim/Vundle.vim";
      flake = false;
    };
    zgen = {
      url = "github:tarjoilija/zgen";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-distroav, impermanence, home-manager, ... }@inputs: {
    # Please replace my-nixos with your hostname
    nixosConfigurations.nixos-musholic-stream = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        pkgs-distroav = import nixpkgs-distroav {
          inherit system;
          config.allowUnfree = true;
        };
      };
      modules = [
        ./musholic-stream
        ./musholic-stream/home.nix
      ];
    };
  };

}
