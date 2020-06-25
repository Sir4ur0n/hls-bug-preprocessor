let

  # Must be the same as the Stack resolver we use!
  ghcCompiler = "ghc883";

in { nixpkgs ? import nix/default.nix { }
, haskell-language-server ? import nix/haskell-language-server.nix { } }:

# By default, all functions/values come fron Nixpkgs
with nixpkgs;

let

  # Wrap Ormolu to add our default extensions that are not enabled by default in Ormolu
  # Run 'ormolu --manual-exts' to find out which extensions are not enabled by default
  # Inspired by https://nixos.wiki/wiki/Nix_Cookbook
  # If for whatever reason you want to reformat the whole code base, run:
  # for f in ./**/*.hs; do
  #   ormolu --mode inplace "$f"
  # done
  ormolu-wrapped = symlinkJoin {
    name = "ormolu";
    paths = [ ormolu ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/ormolu \
        --add-flags "\
          --ghc-opt -XBangPatterns \
          --ghc-opt -XTypeApplications \
        "
    '';
  };

  # Wrap Stack to configure Nix integration and target the correct Stack-Nix file
  # --nix -> Enable Nix support
  # --no-nix-pure -> Pass environment variables (like LOCALES or FEDID_URL)
  # --nix-shell-file nix/stack-integration.nix -> Specify the Nix file to use (otherwise it uses shell.nix by default, which we don't want)
  stack-wrapped = symlinkJoin {
    name = "stack";
    paths = [ stack ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/stack \
        --add-flags "\
          --nix \
          --no-nix-pure \
          --nix-shell-file nix/stack-integration.nix \
        "
    '';
  };

in mkShell {
  # Useful packages for One Catalog, you can manually use `nix-shell` to get a shell with everything configured, or even better, install `direnv`, see `.envrc`
  buildInputs = [
    # Packages needed to build/run the Haskell applications #
    lzma
    zlib
    stack-wrapped

    # Development tools #
    # Formatter
    ormolu-wrapped
    # Code suggestions
    hlint
    # Haddock parsing and search
    haskell.packages.${ghcCompiler}.hoogle

    # Manage Nix package versions easily
    niv
    # Nix file formatter
    nixfmt

    # Language Server Protocol (e.g. to use an LSP plugin in VS Code, Atom, Emacs, etc.) #
    haskell-language-server.exes.haskell-language-server
    haskell-language-server.exes.haskell-language-server-wrapper
  ];

  # Force the Nix path to our frozen set of packages, to ensure Stack-with-Nix uses the correct one rather than the global <nixpkgs>
  # See https://nixos.org/nixos/nix-pills/nix-search-paths.html for more information
  NIX_PATH = "nixpkgs=" + nixpkgs.path;
}
