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
    in pkgs.mkShell {
      packages = with pkgs; [
        texlive.withPackages (ps: with ps; [
          texliveSmall
        ])
      ];

      shellHook = ''
        echo -e "\e[1;32mInside presentation sandbox!\e[0m"
      '';
    };
  };
}
