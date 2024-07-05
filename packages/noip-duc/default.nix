{pkgs}:
pkgs.stdenv.mkDerivation {
  pname = "noip-duc";
  version = "3.1.1";

  src = pkgs.fetchurl {
    url = "https://www.noip.com/download/linux/latest";
    sha256 = "sha256-7/27l3xt8HWu5MS40yxUUgGjtyDPcDFXyYvxZkGgoFA=";
  };

  # The source file format is ".tar.gz" but this cannot be derived from
  # the URL, so tell nix not to unpack. We will unpack it later manually.
  dontUnpack = true;

  buildInputs = with pkgs; [gnutar dpkg];

  installPhase = ''
    mkdir -p $out
    cd $out
    ${pkgs.gnutar}/bin/tar xzf $src
    ${pkgs.dpkg}/bin/dpkg-deb -x $out/noip-duc_3.1.1/binaries/noip-duc_3.1.1_amd64.deb $out
    mkdir -p $out/bin
    install $out/usr/bin/noip-duc $out/bin/noip-duc
    rm -r -f $out/noip-duc_3.1.1 $out/usr
  '';

  # Do not patchElf
  fixupPhase = ":";

  meta = with pkgs.lib; {
    description = "Dynamic DNS Update Client (DUC) for Linux";
    homepage = "https://www.noip.com/download?page=linux";
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    # maintainers = with maintainers; [  ];
    license = licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "noip-duc";
  };
}
