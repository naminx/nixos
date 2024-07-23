{pkgs}:
  pkgs.stdenv.mkDerivation rec {
    pname = "bootnext";
    version = "0.0.2";

    buildInputs = [pkgs.efibootmgr];

    nativeBuildInputs = [pkgs.makeWrapper];

    src = pkgs.fetchurl {
      url = "https://github.com/TensorWorks/bootnext/releases/download/v${version}/bootnext-linux-amd64";
      sha256 = "sha256-RUIRLHUSz4TqRv0pSBagULGd6NDc7wZOMLhi1qvcdrU=";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      install $src $out/bin/bootnext
    '';

    fixupPhase = ''
      runHook postFixup
    '';

    postFixup = ''
      wrapProgram $out/bin/bootnext \
        --prefix PATH : "${pkgs.lib.strings.makeBinPath [pkgs.efibootmgr]}"
    '';

    meta = with pkgs.lib; {
      description = "A simple CLI tool to set the value of the UEFI BootNext NVRAM variable and reboot";
      homepage = "https://github.com/TensorWorks/bootnext";
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "bootnext";
    };
  }
