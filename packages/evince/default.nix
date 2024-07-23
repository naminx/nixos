{pkgs}:
let
  librsvg-with-webp = pkgs.librsvg.overrideAttrs (oldAttrs: {
    pname = oldAttrs.pname + "-with-webp";
    propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [pkgs.webp-pixbuf-loader];
    postInstall =
      builtins.replaceStrings
      ["cat "]
      ["cat ${pkgs.webp-pixbuf-loader}/${pkgs.gdk-pixbuf.binaryDir}/webp-loaders.cache "]
      oldAttrs.postInstall;
  });
in
  (pkgs.evince.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [librsvg-with-webp];
    patches =
      (oldAttrs.patches or [])
      ++ [
        ./patches/0-vim-like-bindings.patch
        ./patches/add-annotation-right-click.patch
        ./patches/add-keyboard-binding-to-toggle-menu-bar.patch
        ./patches/add-save-action-and-make-default.patch
        ./patches/add-web-search-action.patch
        ./patches/custom-commands.patch
        ./patches/initially-hide-menu-bar.patch
        ./patches/zathura-like.patch
      ];
  }))
  .override {
    librsvg = librsvg-with-webp;
  }
