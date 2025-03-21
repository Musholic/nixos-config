{
  description = "System config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-distroav-patch = {
      url = "https://github.com/Musholic/nixpkgs/pull/1.patch";
      flake = false;
    };
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
    nixpkgs-distroav-patch,
    nixpkgs-unstable,
    ...
  }: {
    # Please replace my-nixos with your hostname
    nixosConfigurations.nixos-musholic-stream = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        pkgs-unstable = let
          nixpkgs-patched = (import nixpkgs-unstable {inherit system;}).applyPatches {
            name = "nixpkgs-distroav-patch";
            src = nixpkgs-unstable;
            patches = [nixpkgs-distroav-patch];
          };
        in
          import nixpkgs-patched {
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
