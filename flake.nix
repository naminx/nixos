{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    brc.url = "github:naminx/brc";
    mht2img.url = "github:naminx/mht2img";
    mansuki.url = "github:naminx/mansuki";
  };

  outputs = inputs: let
    secrets = builtins.fromJSON (builtins.readFile "${inputs.self}/secrets.json");

    nixpkgsWithOverlays = rec {
      config.allowUnfree = true;
      config.permittedInsecurePackages = [
        # FIXME:: add any insecure packages you absolutely need here
      ];
      overlays = [
        inputs.nur.overlay
        (_final: prev: let
          mypkg = path: prev.callPackage "${path}/default.nix" {pkgs = prev;};
          myapp = pkg: pkg.packages."x86_64-linux".default;
        in {
          # this allows us to reference pkgs.unstable
          unstable = import inputs.nixpkgs-unstable {
            inherit (prev) system;
            inherit config;
            overlays = [
              # This is how to override unstable packages
              #
              # (_final: prevUnstable: rec {
              #   mcomix = prevUnstable.mcomix.overrideAttrs (o: {
              #     propagatedBuildInputs = with prev.python3.pkgs;
              #       o.propagatedBuildInputs ++ [ send2trash ];
              #     patches = [ ./patches/mcomix-disable-click-to-flip.patch ];
              #   });
              # })
            ];
          };

          # overriden stable packages
          bootnext = mypkg ./packages/bootnext;
          chromium = mypkg ./packages/chromium;
          custom-fonts = mypkg ./packages/custom-fonts;
          evince = mypkg ./packages/evince;
          gnome = mypkg ./packages/gnome;
          google-chrome = mypkg ./packages/google-chrome;
          krita = mypkg ./packages/krita;
          libreoffice-qt-fresh = mypkg ./packages/libreoffice-qt-fresh;
          mcomix = mypkg ./packages/mcomix;
          microsoft-edge = mypkg ./packages/microsoft-edge;
          neovim = mypkg ./packages/neovim;
          noip-duc = mypkg ./packages/noip-duc;
          thorium = mypkg ./packages/thorium;

          # my own apps
          brc = myapp inputs.brc;
          mht2img = myapp inputs.mht2img;
          mansuki = myapp inputs.mansuki;
        })
      ];
    };

    configurationDefaults = args: {
      nixpkgs = nixpkgsWithOverlays;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-backup";
        extraSpecialArgs = args;
      };
    };

    argDefaults = {
      inherit secrets inputs;
      inherit (inputs) self nix-index-database;
      channels = {
        inherit (inputs) nixpkgs nixpkgs-unstable;
      };
    };

    mkNixosConfiguration = {
      system ? "x86_64-linux",
      hostname,
      username,
      args ? {},
      modules,
    }: let
      specialArgs = argDefaults // {inherit hostname username;} // args;
    in
      inputs.nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules =
          [
            (configurationDefaults specialArgs)
            inputs.home-manager.nixosModules.home-manager
          ]
          ++ modules;
      };
  in {
    formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;

    nixosConfigurations.nixos = mkNixosConfiguration {
      hostname = "tokyo";
      username = "namin"; # FIXME: replace with your own username!
      modules = [
        ./configuration.nix
        inputs.nixos-wsl.nixosModules.wsl
      ];
    };
  };
}
