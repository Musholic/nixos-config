
{ config, lib, inputs, pkgs, pkgs-distroav, ... }:
{
  imports =
    [ 
      inputs.home-manager.nixosModules.home-manager
    ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.musholic = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
      rofi-power-menu
      google-chrome
      polybar
      maim # for screenshots
    ];
    shell = pkgs.zsh;
  };

  home-manager.backupFileExtension = "hm-backup";
  home-manager.users.musholic = { pkgs, ... }: {
    imports = [ 
      inputs.impermanence.homeManagerModules.impermanence
    ];
    home.sessionVariables = {
      DISK = "/disk";
    }; 
    xsession.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "24.11";

    home.persistence."/nix/conf/home" = {
      files = with pkgs; let
        listFilesRecursive = dir: acc: lib.flatten (lib.mapAttrsToList
          (k: v: if k == ".nolink" then []
          else if ! builtins.pathExists  (dir + "/${acc}${k}/.nolink") then
          acc + k
          else
          listFilesRecursive dir (acc + k + "/"))
          (builtins.readDir ( dir + "/${acc}")));
  
        in listFilesRecursive ../home "";
    };
    home.file = {
      ".vim/bundle/Vundle.vim".source = inputs.vundle;
      "git/sys/zgen".source = inputs.zgen;
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    programs.rofi = {
      enable=true;
      package = pkgs.rofi-wayland;
      theme = "Adapta-Nokto";
    };

    programs.waybar = {
      enable=true;
      systemd.enable = true;
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs-distroav.obs-studio-plugins; [
        distroav
      ];
    };

    services.ssh-agent.enable = true;

  };
}

