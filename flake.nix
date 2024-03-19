{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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
      beginMark = "# The C-code for this binary wrapper has been generated using the following command:";
      endMark = "# (Use `nix-shell -p makeBinaryWrapper` to get access to makeCWrapper in your shell)";
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets.json");

      nixpkgsWithOverlays = with inputs; rec {
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
            #           pkgs' = import nixpkgs {
            #             inherit (_final) system;
            #             inherit config;
            #           };
            unstable = import nixpkgs-unstable {
              inherit (prev) system;
              inherit config;
              overlays = [
                (_final: prevUnstable: rec {
                  # To circumvent a bug in libtins that affects Mathematica
                  # libtins = prev.libtins;
                  mcomix = prevUnstable.mcomix.overrideAttrs (o: {
                    propagatedBuildInputs = with prev.python3.pkgs;
                      o.propagatedBuildInputs
                      ++ [
                        send2trash
                      ];
                    patches = [
                      ./patches/mcomix-disable-click-to-flip.patch
                      ./patches/mcomix-file-sorting-order.patch
                      ./patches/mcomix-keyboard-bindings.patch
                      ./patches/mcomix-send-to-trash.patch
                      ./patches/mcomix-mouse-wheel.patch
                      ./patches/mcomix-reset-zoom.patch
                    ];
                  });
                })
              ];
            };
            chrome-remote-desktop = prev.callPackage ./chrome-remote-desktop/default.nix {pkgs = prev;};
            lsd = prev.lsd.overrideAttrs (o: {
              patches =
                (o.patches or [])
                ++ [
                  ./patches/lsd-list-by-column.patch
                ];
            });
            krita = prev.krita.overrideAttrs (o: {
              patches =
                (o.patches or [])
                ++ [
                  ./patches/krita-pan-action.patch
                ];
            });
            cachix = unstable.cachix;
            namin-fonts = prev.callPackage ./fonts.nix {pkgs = prev;};
            brc = inputs.brc.packages."x86_64-linux".default;
            mht2img = inputs.mht2img.packages."x86_64-linux".default;
            mansuki = inputs.mansuki.packages."x86_64-linux".default;
            #           gnome =
            #             prev.gnome
            #             // {
            #               nautilus = prev.symlinkJoin {
            #                 name = "${prev.gnome.nautilus.name}-with-thumbnailers";
            #                 version = prev.gnome.nautilus.version;
            #                 paths = [prev.gnome.nautilus];
            #                 nativeBuildInputs = with _final; [gnused makeBinaryWrapper];
            #                 buildInputs = with _final; [bash unzip rar imagemagick];
            #                 postBuild = with _final; ''
            #                   chmod +w $out/share
            #                   mkdir -p $out/share/thumbnailers
            #                   cat > $out/share/thumbnailers/cbz.thumbnailer <<EOF
            #                   [Thumbnailer Entry]
            #                   TryExec=${bash}/bin/bash
            #                   Exec=${bash}/bin/bash -c '${unzip}/bin/unzip -p -- "%i" | ${imagemagick}/bin/magick - -resize "x%s" "%o"'
            #                   MimeType=application/vnd.comicbook+zip;application/x-cbz;application/x-ext-cbz
            #                   EOF

            #                   cat > $out/share/thumbnailers/cbr.thumbnailer <<EOF
            #                   [Thumbnailer Entry]
            #                   TryExec=${bash}/bin/bash
            #                   Exec=${bash}/bin/bash -c '${rar}/bin/unrar p -- "%i" | ${imagemagick}/bin/magick - -resize "x%s" "%o"'
            #                   MimeType=application/vnd.comicbook-rar;application/x-cbr;application/x-ext-cbr
            #                   EOF

            #                   cat > $out/share/thumbnailers/magick.thumbnailer <<EOF
            #                   [Thumbnailer Entry]
            #                   TryExec=${imagemagick}/bin/magick
            #                   Exec=${imagemagick}/bin/magick -define profile:skip=icc -- %i -resize x%s %o
            #                   MimeType=image/jpeg;image/webp;image/png
            #                   EOF

            #                   for i in nautilus nautilus-autorun-software; do
            #                     rm $out/bin/$i
            #                     makeBinaryWrapper "$out/bin/.''${i}-wrapped" "$out/bin/$i" \
            #                       $(${gnused}/bin/sed -n '/${beginMark}/,/${endMark}/p' "${prev.gnome.nautilus}/bin/$i" \
            #                         | ${gnused}/bin/sed -E 's/[[:space:]]/ /g;s/'"'"'|\\//g;1,4d;:a;$d;N;7ba;P;D') \
            #                         --prefix XDG_DATA_DIRS : "$out/share"
            #                   done
            #                 '';
            #               };
            #             };
            evince = prev.symlinkJoin {
              name = "${prev.evince.name}-fixed";
              version = prev.evince.version;
              paths = [prev.evince];
              nativeBuildInputs = with _final; [gnused makeBinaryWrapper];
              buildInputs = with _final; [bash librsvg webp-pixbuf-loader];
              postBuild = let
                loader-path = "lib/gdk-pixbuf-2.0/2.10.0";
                set-pixbuf-module = "--set GDK_PIXBUF_MODULE_FILE";
                old-loader = "${_final.librsvg}/${loader-path}/loaders.cache";
                new-loader = "$out/${loader-path}/loaders.cache";
              in
                with _final;
                  ''
                    chmod +w $out/lib
                    mkdir -p $out/${loader-path}
                    cat "${librsvg}/${loader-path}/loaders.cache" \
                      "${webp-pixbuf-loader}/${loader-path}/webp-loaders.cache" \
                      > "${new-loader}"

                    for i in evince evince-previewer evince-thumbnailer; do
                      rm $out/bin/$i
                      makeBinaryWrapper "$out/bin/.''${i}-wrapped" "$out/bin/$i" \
                        $(${gnused}/bin/sed -n '/${beginMark}/,/${endMark}/p' "${prev.evince}/bin/$i" \
                          | ${gnused}/bin/sed -E 's/[[:space:]]/ /g;s/'"'"'|\\//g''
                  + '';s#(${set-pixbuf-module}) ${old-loader}#\1 '"${new-loader}"'#''
                  + ''                    ;1,4d;:a;$d;N;7ba;P;D')
                                      done
                  '';
            };
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
