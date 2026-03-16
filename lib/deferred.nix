pkgs: let
  deferred = drv: let
    exeName = drv.meta.mainProgram;

    wrapper = pkgs.writeShellApplication {
      name = exeName;
      runtimeInputs = [pkgs.nix];
      text = let
        outPath = builtins.unsafeDiscardStringContext drv.outPath;
        exe = "${outPath}/bin/${exeName}";
      in ''
        nix-store --realise "${outPath}"
        exec "${exe}" "$@"
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
