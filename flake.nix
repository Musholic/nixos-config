{
  description = "System config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-distroav.url = "git+file:///home/musholic/git/nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-distroav, ... }@inputs: {
    # Please replace my-nixos with your hostname
    nixosConfigurations.nixos-musholic-stream = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = {
        pkgs-distroav = import nixpkgs-distroav {
          inherit system;
          config.allowUnfree = true;
        };
      };
      modules = [
        ./musholic-stream
      ];
    };
  };

}
