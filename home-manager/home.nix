{
  lib,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./common/desktop.nix
  ];
  #
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "musholic";
  home.homeDirectory = "/home/musholic";

  # Define a user account. Don't forget to set a password with ‘passwd’.

  home.persistence."/nix/persist/home" = {
    directories = [
      ".config/obs-studio"
    ];
  };

  home.persistence."/nix/conf/file_links" = let
    isFileOrSymlink = path: builtins.readFileType path != "directory";
    isDirectory = path: builtins.readFileType path == "directory";
    listFilesRecursive = dir: acc: matcher:
      lib.flatten (lib.mapAttrsToList
        (k: v:
          if k == ".nolink"
          then []
          else if ! builtins.pathExists (dir + "/${acc}${k}/.nolink")
          then
            (
              if matcher (dir + "/${acc}${k}")
              then acc + k
              else []
            )
          else listFilesRecursive dir (acc + k + "/") matcher)
        (builtins.readDir (dir + "/${acc}")));
  in {
    files = listFilesRecursive ../file_links "" isFileOrSymlink;
    directories = listFilesRecursive ../file_links "" isDirectory;
  };

  programs.obs-studio = {
    enable = true;
    package = pkgs-unstable.obs-studio;
    plugins = with pkgs-unstable.obs-studio-plugins; [
      distroav
    ];
  };
}
