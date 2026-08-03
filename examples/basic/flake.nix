{
  description = "Example NixOS host using johnbarney/nixos-config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-config = {
      url = "github:johnbarney/nixos-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, nixos-config, ... }:
    let
      system = "x86_64-linux";
      hostname = "example";
      username = "alice";
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit hostname username; };
        modules = [
          nixos-config.nixosModules.workstation
          nixos-config.nixosModules.desktop-kde
          nixos-config.nixosModules.display-sddm
          nixos-config.nixosModules.hardware-cpu-amd
          nixos-config.nixosModules.hardware-graphics-amd
          nixos-config.nixosModules.home-manager
          ./hosts/example
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username}.imports = [
              nixos-config.homeModules.default
              nixos-config.homeModules.desktop-kde
              ./home/alice/home.nix
            ];
          }
        ];
      };
    };
}
