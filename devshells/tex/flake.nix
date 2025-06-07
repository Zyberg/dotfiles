{
  description = "Some random stuff for making presentations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11"; # Pin to a stable version
  };

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs { inherit system; };
      mytexlive = (pkgs.texlive.combine {
          inherit (pkgs.texlive)
          latexmk
          scheme-small;
          });
    in pkgs.mkShell {
      packages = with pkgs; [
        mytexlive
      ];

      shellHook = ''
        echo -e "\e[1;32mInside presentation sandbox!\e[0m"
      '';
    };
  };
}
