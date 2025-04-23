{
  description = "System config";

  inputs = {
    nixpkgs-upstream.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:Musholic/nixpkgs/nixos-24.11";
    nixpkgs-patch-1 = {
      url = "https://github.com/Musholic/nixpkgs/commit/a290eed49176a0ed152529ecc33c62b1441949de.patch";
      flake = false;
    };
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
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

  outputs = inputs @ {
    nixpkgs,
    nixpkgs-unstable,
    ...
  }: {
    nixosConfigurations.nixos-musholic-stream = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        pkgs-unstable = let
          nixpkgs-patched = (import nixpkgs-unstable {inherit system;}).applyPatches {
            name = "nixpkgs-distroav-patch";
            src = nixpkgs-unstable;
            patches = [./patches/update_distroav.patch];
          };
        in
          import nixpkgs-patched {
            inherit system;
            config.allowUnfree = true;
          };
      };
      modules = [
        ./modules/hosts/stream
        ./modules/hosts/stream/home.nix
      ];
    };
  };
}
