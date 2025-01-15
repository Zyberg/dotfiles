{ inputs, lib, config, pkgs, ... }:

{
  home = {
    username = "zyberg";
    homeDirectory = "/home/zyberg";
    packages = with pkgs; [
        tofi
        dunst
        clipse
        wl-clipboard
        hyprpaper
        direnv
        gh
        jq
        # Some utility stuff
        ripgrep
        file
  # Some nice fun for direnv + nixos setup on non-nix projects with git ignore
        lua-language-server
    ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
#      XDG_SESSION_TYPE = "wayland";
#      MOZ_ENABLE_WAYLAND = "1";
#      QT_QPA_PLATFORM = "wayland";
#      SDL_VIDEODRIVER = "wayland";
    };
    # TODO: this is a meh way of doing stuff; need to think more
    #sessionPath = [
    #  "~/.local/bin"
    #];
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
    initExtra = ''
      # Source .zshrc.local if it exists
      if [ -f ~/.zshrc.local ]; then
        source ~/.zshrc.local
      fi
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.firefox.enable = true;

  home.file.".config/dunst/dunstrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/fabrikas/config/dunst/dunstrc2";
# Hyprland stuff
  programs.tofi.enable = true;
  programs.kitty.enable = true;

# TODO: This is "dirty", after configuring a good enough system need to use a direct source
  xdg.configFile."hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/fabrikas/config/hypr/hyprland.conf";

xdg.configFile."hypr/hyprpaper.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/fabrikas/config/hypr/hyprpaper.conf";

  home.stateVersion = "23.11";
}
