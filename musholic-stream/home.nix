
{ config, lib, pkgs, pkgs-distroav, ... }:
let
  impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      <home-manager/nixos>
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
   imports = [ "${impermanence}/home-manager.nix" ];
   home.sessionVariables = {
      DISK = "/disk";
    }; 

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
      ".vim/bundle/Vundle.vim".source = builtins.fetchGit  "https://github.com/VundleVim/Vundle.vim.git";
      "git/sys/zgen".source = builtins.fetchGit "https://github.com/tarjoilija/zgen.git";
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

  };
}

