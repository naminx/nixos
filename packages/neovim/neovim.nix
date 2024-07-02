{ pkgs, ... }:
pkgs.neovim.override {
  viAlias = true;
  configure = import ./config.nix {inherit pkgs;};
}
