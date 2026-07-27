# See https://github.com/NixOS/nixpkgs/issues/522307
_: _final: prev: {
  pipx = prev.pipx.overridePythonAttrs (old: {
    disabledTestPaths =
      (old.disabledTestPaths or [])
      ++ [
        "tests/test_inject.py"
      ];

    disabledTests =
      (old.disabledTests or [])
      ++ [
        "test_fix_package_name"
        "test_inject_single_package"
        "test_parse_specifier_for_metadata"
      ];
  });
}
