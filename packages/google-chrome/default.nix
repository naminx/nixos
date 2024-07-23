{pkgs, ...}:
pkgs.google-chrome.override {
  commandLineArgs = [
    "--enable-features=UseOzonePlatform"
    "--ozone-platform=wayland"
    "--enable-wayland-ime"
    "--disable-features=WaylandFractionalScaleV1"
    "--enable-chrome-browser-cloud-management"
    "--gtk-version=4"
  ];
}
