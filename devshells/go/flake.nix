{
  description = "Simple go dev environment flake";

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
        go                 # The Go compiler and toolchain
        gopls              # Go language server for LSP support
        delve              # Go debugger
        golangci-lint      # Popular Go linter aggregator
        go-tools           # Misc Go tools (e.g. stringer, vet, etc.)
        gotests            # Tool to generate Go tests
      ];

      shellHook = ''
        echo -e "\e[1;32mUsing Go development environment!\e[0m"
        echo "Go version $(go version)"

        export ENV_TAG="go"
        export VIRTUAL_ENV="%F{green}(%f%F{blue}$ENV_TAG%f%F{green})%f"
      '';
    };
  };
}
