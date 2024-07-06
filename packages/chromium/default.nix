{pkgs, ...}:
(pkgs.callPackage ./chromium/default.nix {})
.overrideAttrs (oldAttrs: {
  buildCommand =
    builtins.replaceStrings
    ["--enable-features=WaylandWindowDecorations"]
    ["--enable-features=WaylandWindowDecorations --enable-wayland-ime --disable-features=WaylandFractionalScaleV1 --enable-chrome-browser-cloud-management --gtk-version=4"]
    oldAttrs.buildCommand;
})
