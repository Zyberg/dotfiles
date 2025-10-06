{
  description = "Haskell + Neovim development environment flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs { inherit system; };
    in pkgs.mkShell {
      packages = with pkgs; [
        # Core Haskell tools
        ghc
        cabal-install
        haskell-language-server  # Required for LSP in Neovim
        hlint                    # Linter
        fourmolu                 # Formatter (use ormolu if you prefer)
        hoogle                   # Documentation search
        ghcid                    # Live reload / fast feedback

        # Useful dev tools
        pkg-config
        zlib
        openssl

        # Neovim (optional — include if you want a pinned version)
        neovim
      ];

      shellHook = ''
        echo -e "\e[1;35mUsing Haskell + Neovim dev environment!\e[0m"
        echo "GHC:     $(ghc --version | awk '{print $NF}')"
        echo "Cabal:   $(cabal --version | head -n1 | awk '{print $NF}')"
        echo "HLS:     $(${pkgs.haskell-language-server}/bin/haskell-language-server --numeric-version || echo 'not found')"
        echo "Neovim:  $(nvim --version | head -n1 | awk '{print $2}')"

        export ENV_TAG="haskell-nvim"
        export VIRTUAL_ENV="%F{green}(%f%F{blue}$ENV_TAG%f%F{green})%f"
      '';
    };
  };
}

