{
  description = "Simple dotnet8 dev environment flake";

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

        export ENV_TAG="dotnet"
        export VIRTUAL_ENV="%F{green}(%f%F{blue}$ENV_TAG%f%F{green})%f"
      '';
    };
  };
}
