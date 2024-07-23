{pkgs, ...}:
(pkgs.callPackage ./chromium/default.nix {})
.override {
  commandLineArgs = [
    "--enable-wayland-ime"
    "--disable-features=WaylandFractionalScaleV1"
    "--enable-chrome-browser-cloud-management"
    "--gtk-version=4"
  ];
}
