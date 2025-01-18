{
  description = "Simple dotnet8 dev environment flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11"; # Pin to a stable version
  };

  outputs = { self, nixpkgs, ... }: let
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs { 
        inherit system;

        config.permittedInsecurePackages = [
          "openssl-1.1.1w"
        ];
      };
      #patchedOmniSharp = import ./omnisharp-roslyn-patched.nix { inherit pkgs; };
      in pkgs.mkShell {
      packages = with pkgs; [
        dotnet-sdk_8
        # For nvim lsp stuff 
        mono
        openssl
        openssl_1_1
        zlib
        curl
        zlib
        xz
        binutils
        icu
        # TODO: need to use a patched omnisharp version until autoimport bug is fixed
        omnisharp-roslyn
        #patchedOmniSharp
        vimPlugins.omnisharp-extended-lsp-nvim
        # debugger
        netcoredbg
      ];

      shellHook = ''
        echo -e "\e[1;32mUsing .NET development environment!\e[0m"
        echo "Using .NET SDK version: $(dotnet --version)"

        # TODO: this will be extracted. Need to somehow make roslyn build now...
        export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
        export LD_LIBRARY_PATH=${pkgs.openssl_1_1.out}/lib:${pkgs.zlib}/lib:${pkgs.xz}/lib:$LD_LIBRARY_PATH
        export LD_LIBRARY_PATH=${pkgs.icu.out}/lib:$LD_LIBRARY_PATH

        export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

        # Use proper linker from binutils
        export NIX_LD=${pkgs.binutils}/bin/ld
        
        # Some utility stuff to load launchsettings vars into environment
        if [ -f Properties/launchSettings.json ]; then
          eval $(jq -r '
            .profiles.Test.environmentVariables 
            | to_entries 
            | map("export \(.key)=\(.value|@sh)") 
            | .[]
          ' Properties/launchSettings.json)
          echo "Environment variables loaded from launchSettings.json"
        else
          echo "launchSettings.json not found; skipping environment setup"
        fi     '';
    };
  };
}
