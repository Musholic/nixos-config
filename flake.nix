{
  description = "NixOS config for musholic stream host";

  inputs = {
    # Use nix-patcher until we get the following PR https://github.com/NixOS/nix/pull/6530
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
    zed-preview.url = "github:Musholic/zed/v0.184.x";
    zgen = {
      url = "github:tarjoilija/zgen";
      flake = false;
    };
    optinix.url = "gitlab:hmajid2301/optinix";
  };

  outputs = inputs @ {
    nixpkgs,
    nixpkgs-unstable,
    zed-preview,
    home-manager,
    optinix,
    ...
  }: let
    system = "x86_64-linux";
    skimPluginOverlay = import ./overlays/skim.nix;
    pkgs = let
      nixpkgs-patched = (import nixpkgs {inherit system;}).applyPatches {
        name = "nixpkgs-distroav-patch";
        src = nixpkgs;
        patches = [./patches/update_distroav.patch];
      };
    in
      import nixpkgs-patched {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          skimPluginOverlay
        ];
      };
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-zed = zed-preview.packages.${system}.default;

    pkgs-optinix = optinix.packages.${system}.default.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [./patches/optinix-remove-darwin.patch];
    });
  in {
    nixosConfigurations.nixos-musholic-stream = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs pkgs pkgs-unstable pkgs-zed pkgs-optinix;
      };
      modules = [
        ./modules/hosts/stream
      ];
    };
    homeConfigurations.musholic = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs pkgs-unstable pkgs-zed pkgs-optinix;
      };
      modules = [
        ./home-manager/home.nix
      ];
    };
  };
}
