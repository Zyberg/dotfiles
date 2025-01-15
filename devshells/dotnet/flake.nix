{
  description = "Simple dotnet8 dev environment flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11"; # Pin to a stable version
  };

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs { inherit system; };
    in pkgs.mkShell {
      # Include Node.js, pnpm, and yarn
      packages = with pkgs; [
        dotnet-sdk_8
      ];

      # Optional: Custom messages or actions when entering the shell
      shellHook = ''
        echo -e "\e[1;32mUsing .NET development environment!\e[0m"
        echo "Using .NET SDK version: $(dotnet --version)"
      '';
    };
  };
}
