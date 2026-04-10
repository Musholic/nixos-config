pkgs: let
  deferred = drv: let
    exeName = drv.meta.mainProgram;

    wrapper = pkgs.writeShellApplication {
      name = exeName;
      runtimeInputs = [pkgs.nix];
      text = let
        drvPath = builtins.unsafeDiscardStringContext drv.drvPath;
      in ''
        # Avoid garbage collection
        GC_ROOT="''${XDG_STATE_HOME:-$HOME/.local/state}/nix-deferred/${exeName}"
        mkdir -p "$(dirname "$GC_ROOT")"

        OUT_PATH=$(nix-build "${drvPath}" --out-link "$GC_ROOT")

        exec "$OUT_PATH/bin/${exeName}" "$@"
      '';
    };
  in
    wrapper
    # Support for override and for the run sub-derivations like in pkgs.steam.run
    // {
      override = args: deferred (drv.override args);
    }
    // pkgs.lib.optionalAttrs (drv ? run) {
      run = deferred drv.run;
    };
in
  deferred
