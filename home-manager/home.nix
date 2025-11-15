{ inputs, lib, config, pkgs, ... }:


let
  onModifyPatched = 
    pkgs.runCommand "on-modify.timewarrior" { } ''
      cp ${pkgs.timewarrior}/share/doc/timew/ext/on-modify.timewarrior $out
      chmod +w $out
      substituteInPlace $out --replace '#!/usr/bin/env python3' '#!${pkgs.python3}/bin/python3'
      chmod 0555 $out
    '';
in
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
        hyprshot
        direnv
        gh
        jq
        sioyek
        # Some utility stuff
        ripgrep
        file

        taskwarrior3
        timewarrior
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

  programs.git = {
    enable = true;
    userName = "zyberg";
    userEmail = "nikolajus.elkana@gmail.com";
  };

  programs.lazygit.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake ~/fabrikas/#fabrikas";
    };
    initContent = ''
      # Source .zshrc.local if it exists
      if [ -f ~/.zshrc.local ]; then
        source ~/.zshrc.local
      fi

      setopt PROMPT_SUBST

      show_virtual_env() {
        if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
          echo "$(basename $VIRTUAL_ENV)"
        fi
      }

      PS1=$PS1
    '';
  };

  services.recoll = {
    enable = true;

    settings = {
      loglevel = 5;
      topdirs = [ "~/Downloads" "~/Documents" ];

      "~/Downloads" = {
        "skippedNames+" = [ "*.iso" ".git" ".hg" ];
      };
    }
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

  home.file.".taskrc".text = ''
    data.location=${config.xdg.dataHome}/task

    confirmation=no
    verbose=nothing
  '';

  home.file.".local/share/task/hooks/on-modify.timewarrior" = {
    source = onModifyPatched;
    executable = true;
  };

  home.stateVersion = "23.11";
}
