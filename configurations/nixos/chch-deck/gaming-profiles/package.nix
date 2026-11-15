{
  pkgs,
  settings,
}: let
  python = pkgs.python3.withPackages (ps: [ps.python-xlib]);
  configFile = pkgs.writeText "deck-gaming-profiles.json" (builtins.toJSON settings);
in
  pkgs.stdenv.mkDerivation {
    pname = "deck-gaming-profiles";
    version = "1";
    passthru.settingsFile = configFile;
    src = pkgs.lib.cleanSourceWith {
      src = ./.;
      filter = path: type: type == "directory" || pkgs.lib.hasSuffix ".py" path || builtins.baseNameOf path == "display-info.c";
    };
    nativeBuildInputs = [pkgs.makeWrapper pkgs.pkg-config python];
    buildInputs = [pkgs.libdrm];
    buildPhase = ''
      runHook preBuild
      $CC $(pkg-config --cflags libdrm) display-info.c -o deck-display-info $(pkg-config --libs libdrm)
      runHook postBuild
    '';
    doCheck = true;
    checkPhase = ''
      runHook preCheck
      export DECK_PROFILES_TEST_CONFIG=${configFile}
      ${python}/bin/python -m unittest discover -p 'test_*.py'
      runHook postCheck
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/lib/deck-gaming-profiles" "$out/bin"
      cp runtime.py policy.py power.py "$out/lib/deck-gaming-profiles/"
      install -m755 deck-display-info "$out/bin/deck-display-info"
      makeWrapper ${python}/bin/python "$out/bin/deck-gaming-profiles" \
        --add-flags "$out/lib/deck-gaming-profiles/runtime.py --config ${configFile}" \
        --prefix PATH : "$out/bin:${pkgs.lib.makeBinPath [pkgs.jovianPackages.gamescope]}"
      makeWrapper ${python}/bin/python "$out/bin/deck-gaming-power" \
        --add-flags "$out/lib/deck-gaming-profiles/power.py"
      runHook postInstall
    '';
  }
