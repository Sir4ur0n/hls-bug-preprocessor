# Unfortunately, Niv doesn't yet support submodule (see https://github.com/nmattia/niv/issues/58), so we have to manually create the fetch etc.
{ nixpkgs ? import ./. { } }:

with nixpkgs;

let

  # To find the sha256:
  # nix-prefetch-url --unpack https://github.com/haskell/haskell-language-server/<git commit>.tar.gz
  hls-sources = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "haskell";
    repo = "haskell-language-server";
    rev = "a9f96277a37624072d60bdc7f9e5c2241c9ae785";
    sha256 = "0yzdwmbm4k03gxp41ivsq0qh9w21h5l3ihdsr48h1da57ml2zsy0";
  };

  hls-project = with haskell-nix;
    project {
      src = cleanSourceHaskell {
        src = hls-sources;
        name = "hls-source";
      };

      projectFileName = "stack-8.8.3.yaml";
    };

in hls-project.haskell-language-server.components
