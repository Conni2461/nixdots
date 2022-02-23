{ flake }:
[
  (self: super:
    let
      unstable = import flake.unstable { overlays = [ ]; config = { allowUnfree = true; }; system = super.stdenv.hostPlatform.system; };
    in
    {
      examiner = super.callPackage ./examiner.nix { };
    })
  (import (builtins.fetchTarball {
    url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
  }))
]
