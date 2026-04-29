_: _: prev: {
  python313Packages = prev.python313Packages.overrideScope (
    _: pyPrev: {
      fastmcp = pyPrev.fastmcp.overridePythonAttrs (_old: {
        doCheck = false;
      });
    }
  );
}
