{inputs, ...}: {
  imports = [
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    pre-commit.settings.hooks = {
      alejandra.enable = true;
      check-yaml.enable = true;
      deadnix.enable = true;
      end-of-file-fixer.enable = true;
      markdownlint.enable = true;
      shellcheck.enable = true;
      statix.enable = true;
      shfmt.enable = true;
      yamllint.enable = true;
    };
    devShells.default = pkgs.mkShell {
      name = "dotfiles-shell";
      meta.description = "Shell environment for modifying this Nix configuration";
      packages = with pkgs;
        [
          just
          nh
        ]
        ++ config.pre-commit.settings.enabledPackages;

      shellHook = ''
        ${config.pre-commit.installationScript}
      '';
    };
  };
}
