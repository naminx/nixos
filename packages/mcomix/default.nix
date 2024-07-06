{pkgs}:
pkgs.mcomix.overrideAttrs (oldAttrs: {
  propagatedBuildInputs =
    oldAttrs.propagatedBuildInputs ++ [pkgs.python3.pkgs.send2trash];
  patches =
    (oldAttrs.patches or [])
    ++ [
      ./patches/disable-click-to-flip.patch
      ./patches/file-sorting-order.patch
      ./patches/keyboard-bindings.patch
      ./patches/send-to-trash.patch
      ./patches/mouse-wheel.patch
      ./patches/reset-zoom.patch
    ];
})
