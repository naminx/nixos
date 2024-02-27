let
  pkgs = import <nixpkgs> {};
in
  pkgs.stdenv.mkDerivation {
    name = "dwservice-agent";
    src = fetchGit {
      url = "https://github.com/naminx/agent";
      rev = "0790a116534c621217d7e97145393bb5840c18c8";
    };
    phases = ["buildPhase" "installPhase"];

    buildInputs = with pkgs; [
      gcc
      gnumake
      python3
      xorg.libX11.dev
      xorg.libXpm.dev
      xorg.libXi.dev
      xorg.libXext
      xorg.libXtst
      xorg.libXdamage
      xorg.libXfixes
      # libpulseaudio
    ];

    unpackPhase = "true";

    buildPhase = ''
      buildDir=$PWD/agent
      mkdir -p $buildDir
      cp -r $src/* $buildDir
      chmod -R +w $buildDir
      cd $buildDir/make
      python compile_all.py
    '';

    installPhase = ''
      cp -r $buildDir $out
    '';
  }
