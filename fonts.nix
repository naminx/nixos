{
  lib,
  fetchzip,
  ...
}: let
  # version = "1.0.1";
  version = "0cfeeb1cc2b29c8e8cc9557431bc1171d5e32467";
in
  fetchzip {
    name = "namin-fonts-${version}";

    # url = "https://github.com/naminx/myfonts/archive/refs/tags/${version}.zip";
    url = "https://github.com/naminx/myfonts/archive/${version}.zip";

    postFetch = ''
    '';

    sha256 = "1fpn5haqzvcm45cib6ibm1gvf8jnsnsjchh9pkr58v9wa1if78vb";

    meta = with lib; {
      homepage = "https://github.com/namin/myfonts";
      description = "Namin's favorite fonts";
      license = licenses.ofl;
      platforms = platforms.all;
    };
  }
