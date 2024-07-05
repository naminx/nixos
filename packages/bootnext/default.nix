{pkgs}:
  pkgs.stdenv.mkDerivation rec {
    pname = "bootnext";
    version = "0.0.2";

    src = pkgs.fetchurl {
      url = "https://github.com/TensorWorks/bootnext/releases/download/v${version}/bootnext-linux-amd64";
      sha256 = "sha256-RUIRLHUSz4TqRv0pSBagULGd6NDc7wZOMLhi1qvcdrU=";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      install $src $out/bin/bootnext
    '';

    fixupPhase = ":";

    meta = with pkgs.lib; {
      description = "A simple CLI tool to set the value of the UEFI BootNext NVRAM variable and reboot";
      homepage = "https://github.com/TensorWorks/bootnext";
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      # maintainers = with maintainers; [  ];
      license = licenses.mit;
      platforms = ["x86_64-linux"];
      mainProgram = "bootnext";
    };
  }
