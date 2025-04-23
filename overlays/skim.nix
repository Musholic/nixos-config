final: prev: {
  nushellPlugins =
    prev.nushellPlugins
    // {
      skim = prev.nushellPlugins.skim.overrideAttrs (oldAttrs: rec {
        version = "0.10.0";
        src = final.fetchFromGitHub {
          owner = "idanarye";
          repo = "nu_plugin_skim";
          tag = "v0.10.0";
          hash = "sha256-ZqAlOzD1aU4vwcBuVKBskGFTDFA2RKI7gK6apBy+sxc=";
        };
        cargoHash = "";

        cargoDeps = oldAttrs.cargoDeps.overrideAttrs {
          inherit src;
          outputHash = "sha256-RfJJSjUwqtNigxahWhE7w4HcPQe0OJ9VLfASBSyQ8o0=";
        };
      });
    };
}
