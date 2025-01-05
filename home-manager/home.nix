{ inputs, lib, config, pkgs, ... }:

{
  home = {
    username = "zyberg";
    homeDirectory = "/home/zyberg";
    packages = with pkgs; [
      tofi
# TODO: one day I shall move these to a dev environemnt flake or smth
        lua-language-server
        omnisharp-roslyn
        dotnet-sdk
        vimPlugins.omnisharp-extended-lsp-nvim
    ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
#      XDG_SESSION_TYPE = "wayland";
#      MOZ_ENABLE_WAYLAND = "1";
#      QT_QPA_PLATFORM = "wayland";
#      SDL_VIDEODRIVER = "wayland";
    };
  };

  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraWrapperArgs = [
      "--prefix"
        "PATH"
        ":"
        "${lib.makeBinPath [ pkgs.gcc ]}"
    ];
  };
# TODO: This is "dirty", after configuring a good enough system need to use a direct source
  home.file.".config/nvim/init.lua".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/fabrikas/config/nvim/init.lua";
  home.file.".config/nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/fabrikas/config/nvim/lua";
  home.file.".config/nvim/spell".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/fabrikas/config/nvim/spell";

#programs.lua-language-server.enable = true;

  programs.git = {
    enable = true;
    userName = "zyberg";
    userEmail = "nikolajus.elkana@gmail.com";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake ~/fabrikas/#fabrikas";
    };
  };

  programs.firefox.enable = true;

# Hyprland stuff
  programs.tofi.enable = true;
  programs.kitty.enable = true;

# TODO: This is "dirty", after configuring a good enough system need to use a direct source
  xdg.configFile."hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/fabrikas/config/hypr/hyprland.conf";

  home.stateVersion = "23.11";
}
