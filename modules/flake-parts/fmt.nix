{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    # provide the formatter for `nix fmt`
    formatter = config.treefmt.build.wrapper;

    # configure treefmt
    treefmt = {
      projectRootFile = "flake.nix";
      enableDefaultExcludes = true;

      programs = {
        nixfmt = {
          enable = true;
          package = pkgs.alejandra;
        };
      };
    };
  };
}
