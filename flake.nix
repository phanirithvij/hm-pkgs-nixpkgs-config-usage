{
  description = "allowUnfree with nixos module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      nixpkgs,
      home-manager,
      darwin,
      ...
    }:
    let
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
      };
      pkgs = import nixpkgs {
        inherit system config;
      };
      unfreePkgs = P: [ P.python3.pkgs.python-pipedrive ];
    in
    {
      nixosConfigurations.test = nixpkgs.lib.nixosSystem {
        inherit system;
        # inherit pkgs;
        modules = [
          home-manager.nixosModules.home-manager
          # { nixpkgs.pkgs = pkgs; }
          { nixpkgs.config = config; }
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.test =
              { pkgs, ... }:
              {
                home.homeDirectory = "/home/test";
                home.username = "test";
                home.stateVersion = "25.05";
                home.packages = unfreePkgs pkgs;
              };
          }
          (
            { pkgs, ... }:
            {
              fileSystems."/".device = "/dev/null";
              boot.loader.grub.devices = [ "/dev/null" ];
              system.stateVersion = "25.05";
              users.users.test = {
                isNormalUser = true;
              };
              environment.systemPackages = unfreePkgs pkgs;
            }
          )
        ];
      };
      darwinConfigurations.test = darwin.lib.darwinSystem {
        inherit pkgs;
        modules = [
          home-manager.darwinModules.home-manager
          { nixpkgs.config.allowUnfree = true; }
          {
            home-manager.useGlobalPkgs = true;
            home-manager.users.test =
              { pkgs, ... }:
              {
                # home.homeDirectory = "/Users/test";
                home.username = "test";
                home.stateVersion = "25.05";
                home.packages = unfreePkgs pkgs;
              };
          }
          (
            { pkgs, ... }:
            {
              system.stateVersion = 6;
              users.users.test = {
                home = "/Users/test";
              };
              environment.systemPackages = unfreePkgs pkgs;
            }
          )
        ];
      };
    };
}
