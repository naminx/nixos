{
  lib,
  fetchzip,
  ...
}: let
  version = "1.0.3";
in
  fetchzip {
    name = "namin-fonts-${version}";

    url = "https://github.com/naminx/myfonts/archive/refs/tags/${version}.zip";
    # url = "https://github.com/naminx/myfonts/archive/${rev}.zip";

    sha256 = "sha256-ZlQjEddZE4y33dvmODCVsPtiVaSGpJPmGFGVkvc1G9s=";

    meta = with lib; {
      homepage = "https://github.com/namin/myfonts";
      description = "Namin's favorite fonts";
      license = licenses.ofl;
      platforms = platforms.all;
    };
  }
