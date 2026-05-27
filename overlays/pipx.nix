# See https://github.com/NixOS/nixpkgs/issues/522307
_: _final: prev: {
  pipx = prev.pipx.overridePythonAttrs (old: {
    disabledTests =
      (old.disabledTests or [])
      ++ [
        "test_fix_package_name"
        "test_parse_specifier_for_metadata"
      ];
  });
}
