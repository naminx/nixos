{
  lib,
  fetchzip,
}: let
  version = "1.0.1";
in
  fetchzip {
    name = "namin-fonts-${version}";

    url = "https://github.com/naminx/myfonts/archive/refs/tags/${version}.zip";

    postFetch = ''
    '';

    sha256 = "016nqpq47zmfi51m8182hzldzvbzwzxrkk6w680d0zhsb9zwmq2m";

    meta = with lib; {
      homepage = "https://github.com/namin/myfonts";
      description = "Namin's favorite fonts";
      license = licenses.ofl;
      platforms = platforms.all;
    };
  }
