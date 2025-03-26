{
  lib,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.musholic = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
      rofi-power-menu
      google-chrome
      polybar
      maim # for screenshots
      xfce.thunar
      clipse
      wl-clipboard
      grim
      slurp
      ## For use with zeditor
      pkgs-unstable.zed-editor
      nixd
      nil
      alejandra
    ];
    shell = pkgs.zsh;
    hashedPasswordFile = "/nix/persist/hashedPassword.txt";
  };

  home-manager.backupFileExtension = "hm-backup";
  home-manager.users.musholic = {pkgs, ...}: {
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
    home.persistence."/nix/persist/home" = {
      files = [
        ".local/share/zed"
        ".config/google-chrome"
        ".config/obs-studio"
        ".zsh_history"
        ".ssh"
      ];
    };

    home.persistence."/nix/conf/home" = {
      files = let
        listFilesRecursive = dir: acc:
          lib.flatten (lib.mapAttrsToList
            (k: v:
              if k == ".nolink"
              then []
              else if ! builtins.pathExists (dir + "/${acc}${k}/.nolink")
              then acc + k
              else listFilesRecursive dir (acc + k + "/"))
            (builtins.readDir (dir + "/${acc}")));
      in
        listFilesRecursive ../home "";
    };
    home.file = {
      ".vim/bundle/Vundle.vim".source = inputs.vundle;
      "git/sys/zgen".source = inputs.zgen;
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      theme = "Adapta-Nokto";
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs-unstable.obs-studio-plugins; [
        distroav
      ];
    };

    services.ssh-agent.enable = true;

    programs.zsh = {
      enable = true;
      shellAliases = {
        update2 = "nixos-rebuild --use-remote-sudo --show-trace -I nixos-config=/nix/conf switch";
      };
    };
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.gnome-themes-extra;
      };
    };
  };
}
