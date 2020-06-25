let

  sources = import ./sources.nix;

  # Additional customizations on Nixpkgs
  overlay = self: super: {
    haskell = super.haskell // {
      packageOverrides = hself: hsuper: {
        # Tests fails, so ignore them
        time-compat = super.haskell.lib.dontCheck hsuper.time-compat;
      };
    };
  };

  # Add our custom args to Haskell.nix default args
  customizeArgs = args:
    args // {
      overlays = args.overlays ++ [ overlay ];
      config = { allowBroken = true; };
    };

in { haskellNix ? import sources."haskell.nix" { }
, nixpkgsSrc ? haskellNix.sources.nixpkgs-2003
, nixpkgsArgs ? haskellNix.nixpkgsArgs
, nixpkgs ? import nixpkgsSrc (customizeArgs nixpkgsArgs) }:

# This contains:
# * the standard nixpkgs from https://github.com/NixOS/nixpkgs
# * the haskell.nix additional Haskell infrastructure from https://github.com/input-output-hk/haskell.nix (e.g. for easier Stack/Cabal build)
# * some customizations (see overlay) specific to our needs
nixpkgs
