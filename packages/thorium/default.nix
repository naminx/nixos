{pkgs}:
(pkgs.callPackage (builtins.fetchurl {
  url = "https://github.com/NixOS/nixpkgs/raw/ea8378fb8e5c5989b9d0980d89bc978ae6db2d87/pkgs/by-name/th/thorium-browser/package.nix";
  sha256 = "sha256-xaq8KB5CBokTGRGs+5m9CXVuMYTtVFYmgwMeCuw69nU=";
}) {})
.overrideAttrs (oldAttrs: {
  version = "124.0.6367.218";
  src = builtins.fetchurl {
    url = "https://github.com/naminx/thorium.deb/raw/91f91595483613d8d3893dfcbcdf41d065dd4d1c/thorium-browser_124.0.6367.218_amd64.deb";
    sha256 = "sha256-7r6c3BSzvM1OETNa7WyXfpdBqe9U6lJE2Lr5FYZEXek=";
  };
  installPhase =
    builtins.replaceStrings
    ["--enable-features=WaylandWindowDecorations"]
    ["--enable-features=WaylandWindowDecorations --enable-wayland-ime --disable-features=WaylandFractionalScaleV1 --enable-chrome-browser-cloud-management --gtk-version=4"]
    oldAttrs.installPhase;
})
