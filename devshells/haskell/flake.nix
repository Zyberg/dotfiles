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
      packages = (
        # Haskell toolchain from haskellPackages
        with pkgs.haskellPackages; [
          ghc
          cabal-install
          haskell-language-server
          hlint
          fourmolu            # or ormolu
          hoogle
          ghcid
        ]
      ) ++ [
        # native deps commonly needed
        pkgs.pkg-config
        pkgs.zlib
        pkgs.openssl

        # optional: pin neovim from nixpkgs
        # pkgs.neovim
      ];

      shellHook = ''
        echo -e "\e[1;35mUsing Haskell + Neovim dev environment!\e[0m"
        echo "GHC:     $(ghc --version | awk '{print $NF}')"
        echo "Cabal:   $(cabal --version | head -n1 | awk '{print $NF}')"
        echo "HLS:     $(haskell-language-server --numeric-version 2>/dev/null || echo 'not found')"
        echo "Hoogle:  $(hoogle --version 2>/dev/null || echo 'not found')"

        export ENV_TAG="haskell-nvim"
        export VIRTUAL_ENV="%F{green}(%f%F{blue}$ENV_TAG%f%F{green})%f"
      '';
    };
  };
}

