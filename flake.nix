{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    # nixos-wsl = {
    #   url = "github:nix-community/NixOS-WSL";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    brc.url = "github:naminx/brc";
    mht2img.url = "github:naminx/mht2img";
    mansuki.url = "github:naminx/mansuki";
  };

  outputs = inputs:
    with inputs; let
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets.json");

      nixpkgsWithOverlays = rec {
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            # FIXME:: add any insecure packages you absolutely need here
            "python-2.7.18.7" # needed for core-utils
            "nix-2.16.2"
          ];
        };
        overlays = [
          nur.overlay
          (_final: prev: rec {
            # this allows us to reference pkgs.unstable
            unstable = import nixpkgs-unstable {
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
            bootnext = prev.callPackage ./packages/bootnext/bootnext.nix {pkgs = prev;};
            chromium = prev.callPackage ./packages/chromium/chromium.nix {pkgs = prev;};
            custom-fonts = prev.callPackage ./packages/fonts/custom-fonts.nix {pkgs = prev;};
            evince = prev.callPackage ./packages/evince/evince.nix {pkgs = prev;};
            krita = prev.callPackage ./packages/krita/krita.nix {pkgs = prev;};
            mcomix = prev.callPackage ./packages/mcomix/mcomix.nix {pkgs = prev;};
            noip-duc = prev.callPackage ./packages/noip-duc/noip-duc.nix {pkgs = prev;};
            neovim = prev.callPackage ./packages/neovim/neovim.nix {pkgs = prev;};
            thorium = prev.callPackage ./packages/thorium/thorium.nix {pkgs = prev;};

            brc = inputs.brc.packages."x86_64-linux".default;
            mht2img = inputs.mht2img.packages."x86_64-linux".default;
            mansuki = inputs.mansuki.packages."x86_64-linux".default;
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
        inherit secrets inputs self nix-index-database;
        channels = {
          inherit nixpkgs nixpkgs-unstable;
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
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules =
            [
              (configurationDefaults specialArgs)
              home-manager.nixosModules.home-manager
            ]
            ++ modules;
        };
    in {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

      nixosConfigurations.nixos = mkNixosConfiguration {
        hostname = "tokyo";
        username = "namin"; # FIXME: replace with your own username!
        modules = [
          # nixos-wsl.nixosModules.wsl
          ./configuration.nix
        ];
      };
    };
}
