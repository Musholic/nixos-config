{
  description = "System config";

  inputs = {
    nixpkgs-upstream.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:Musholic/nixpkgs/nixos-24.11";
    # nixpkgs.url = "git+file:///home/musholic/git/nixpkgs-24.11";
    nixpkgs-patch-1 = {
      url = "./patches/grub_skip_bind_mount.patch";
      flake = false;
    };
    nixpkgs-unstable-upstream.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:Musholic/nixpkgs/nixos-unstable";
    # nixpkgs-unstable.url = "git+file:///home/musholic/git/nixpkgs-unstable";
    nixpkgs-unstable-patch-1 = {
      url = "./patches/update_distroav.patch";
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
    nixpkgs-unstable,
    ...
  }: {
    nixosConfigurations.nixos-musholic-stream = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        pkgs-unstable = import nixpkgs-unstable {
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
