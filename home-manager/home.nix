{
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.impermanence.homeManagerModules.impermanence
    ./common
  ];
  #
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "musholic";
  home.homeDirectory = "/home/musholic";

  # Define a user account. Don't forget to set a password with ‘passwd’.

  home.persistence."/nix/persist/home" = {
    files = [
      ".local/share/zed"
      ".config/google-chrome"
      ".config/obs-studio"
      ".zsh_history"
      ".ssh"
    ];
  };

  home.persistence."/nix/conf/file_links" = {
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
      listFilesRecursive ../file_links "";
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      distroav
    ];
  };
}
