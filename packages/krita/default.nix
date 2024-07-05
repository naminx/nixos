{pkgs}:
pkgs.krita.override {
  unwrapped = pkgs.krita.unwrapped.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or []) ++ [./patches/pan-action.patch];
  });
}
