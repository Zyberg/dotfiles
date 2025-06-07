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
      packages = with pkgs; [
        dotnet-sdk_8
        # For nvim lsp stuff 
        roslyn-ls
        netcoredbg
        #omnisharp-roslyn
        #vimPlugins.omnisharp-extended-lsp-nvim
      ];

      shellHook = ''
        echo -e "\e[1;32mUsing .NET development environment!\e[0m"
        echo "Using .NET SDK version: $(dotnet --version)"
      '';
    };
  };
}
