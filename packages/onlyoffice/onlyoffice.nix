{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.onlyoffice;

  x11Fonts = pkgs.runCommand "X11-fonts" {preferLocalBuild = true;} ''
    mkdir -p "$out"
    font_regexp='.*\.\(ttf\|ttc\|otf\|pcf\|pfa\|pfb\|bdf\)\(\.gz\)?'
    find ${toString config.fonts.packages} -regex "$font_regexp" \
      -exec cp '{}' "$out" \;
    cd "$out"
    ${pkgs.gzip}/bin/gunzip -f *.gz
    ${pkgs.xorg.mkfontscale}/bin/mkfontscale
    ${pkgs.xorg.mkfontdir}/bin/mkfontdir
    cat $(find ${pkgs.xorg.fontalias}/ -name fonts.alias) >fonts.alias
  '';

  mkFHSEnv = onlyofficeUnwrapped:
    pkgs.buildFHSUserEnvBubblewrap rec {
      name = "onlyoffice";

      # Originally `runScript = "DesktopEditors";` This does not work for me.
      # the error is "DesktopEditors: No such file or directory".

      # My next attempt is to supply an absolute path:
      # runScript = "${onlyofficeUnwrapped}/bin/DesktopEditors"
      # However, I still get "No such file or directory".

      # A peek in /nix/store reveals that this file is in ${...}/bin.
      # runScript = "${onlyofficeUnwrapped}/bin/onlyoffice-desktopeditors";
      # This runs, but does not let OnlyOffice access to system fonts,
      # whether from cmd `onlyoffice ...` or from Nautilus.

      # Unfortunately, `onlyofficeUnwrapped` does not contain other binaries.
      # So we have to find the required binary in its base package.
      # (`onlyofficeUnwrapped` is a buildFSHEnv package.)  I have to look at
      # the source to find how to access the original package. The attribute
      # we need is `onlyofficeUnwrapped.args.targetPkgs`, which is a function.
      # We have to call it with an argument (let's make it `{}`), it will
      # return a list of packages. We find the first package whose `pname
      # attribute is "onlyoffice-desktopeditors". The path to this package
      # is the path we want.

      # I could have used easier ways to get the package from `targetPkgs`,
      # either `lib.lists.elemAt (onlyofficeUnwrapped.args.targetPkgs {}) 1`
      # `builtins.head (builtins.tail (onlyofficeUnwrapped.args.targetPkgs {}))`
      # However, both relies on that the onlyoffice package must come the
      # second element of the list, which is a risky assumption and may break
      # in a future version.

      runScript = "${
        lists.findFirst
        (p: builtins.match "onlyoffice-desktopeditors" p.pname != null)
        null
        (onlyofficeUnwrapped.args.targetPkgs {})
      }/bin/DesktopEditors";
      extraBwrapArgs = [
        "--tmpfs /usr/share"
        "--symlink ${x11Fonts} /usr/share/fonts"
      ];

      targetPkgs = pkgs': [onlyofficeUnwrapped];

      extraInstallCommands = ''
        mkdir -p $out/share/applications
        ln -s ${onlyofficeUnwrapped}/share/icons $out/share
        cp ${onlyofficeUnwrapped}/share/applications/onlyoffice-desktopeditors.desktop $out/share/applications
        substituteInPlace $out/share/applications/onlyoffice-desktopeditors.desktop \
          --replace "${onlyofficeUnwrapped}/bin/onlyoffice-desktopeditors" "$out/bin/onlyoffice"
      '';
    };
in {
  options = {
    programs.onlyoffice = {
      enable = mkOption {
        type = types.bool;
        default = false;
        defaultText = literalExpression "false";
        description = lib.mdDoc ''
          Whether to install the onlyoffice desktop application with access to system fonts.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.onlyoffice-bin;
        defaultText = lib.literalExpression "pkgs.onlyoffice-bin";
        description = "The package providing onlyoffice.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [(mkFHSEnv cfg.package)];
  };
}
