{ inputs, config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];
  
  boot.kernelPackages = pkgs.linuxPackages_6_1;
  # Bluetooth stuff
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

#this isfor now only 
virtualisation.docker.enable = true;


  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
    # probably no need for these ;D
    gotools
    libxml2
    libvirt
    clang
    augeas
  ];

# Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "fabrikas";

# Enable networking
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
#  nix.settings.substituters = [ "https://hyprland.cachix.org" ];
#  nix.settings.trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];

# Set your time zone.
  time.timeZone = "Europe/Vilnius";

# Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

# Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.zyberg = {
    isNormalUser = true;
    description = "Nikolajus Elkana";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      zyberg = import ../home-manager/home.nix;
    };
  };

# List packages installed in system profile. To search, run:
# $ nix search wget
  environment.systemPackages = with pkgs; [
    pkgs.brightnessctl
    pkgs.discord-ptb
    pkgs.home-manager
    emacs-nox
  ];

# TODO: figure out why I must do this here for steam to work. Probably jumbled something up with flakes structure...
  nixpkgs.config.allowUnfree = true;
  programs.steam.enable = true;

  programs.zsh.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.syncthing = {
    enable = true;
    user = "zyberg";
    dataDir = "/home/zyberg/Documents";
    configDir = "/home/zyberg/.config/syncthing";
    openDefaultPorts = true;
  };

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;  # use keys
    };
  };
# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# List services that you want to enable:

# Enable the OpenSSH daemon.
# services.openssh.enable = true;

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It‘s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
