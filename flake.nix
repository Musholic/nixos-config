{
  description = "NixOS config for musholic stream host";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    vundle = {
      url = "github:VundleVim/Vundle.vim";
      flake = false;
    };
    zed-preview.url = "github:zed-industries/zed/v0.214.1-pre";
    zgen = {
      url = "github:tarjoilija/zgen";
      flake = false;
    };
    # While build is failing and until next release: https://gitlab.com/hmajid2301/optinix/-/commits/main?ref_type=HEADS
    optinix.url = "gitlab:hmajid2301/optinix/d274db25e577762fc0d9b5c131022b5907e26d6c";
    nushell-plugin-git-aliases = {
      url = "github:KamilKleina/git-aliases.nu";
      flake = false;
    };
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
      };
    pkgs-unstable = let
      nixpkgs-unstable-patched = (import nixpkgs-unstable {inherit system;}).applyPatches {
        name = "nixpkgs-unstable-patched";
        src = nixpkgs-unstable;
        patches = [./patches/nixpkgs-unstable/carapace.patch];
      };
    in
      import nixpkgs-unstable-patched {
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
    nixosConfigurations.nixos-cloud = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs pkgs pkgs-unstable pkgs-zed pkgs-optinix;
      };
      modules = [
        ./modules/hosts/cloud
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

  nixConfig = {
    extra-substituters = [
      "https://zed.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
      "https://musholic.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "musholic.cachix.org-1:9jEpeBICbnSv6JVQ5PKs1of1A3Wx5QJolfXZke45Uyw="
    ];
  };
}
