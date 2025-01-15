{
  description = "Simple lua dev environment flake";

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
        lua
        luarocks
        # For nvim lsp stuff 
        lua-language-server
      ];

      shellHook = ''
        echo -e "\e[1;32mUsing Lua development environment!\e[0m"
        echo "Using Lua version: $(lua -v)"
      '';
    };
  };
}
