{inputs, ...}: {
  imports = [
    inputs.git-hooks-nix.flakeModule
    inputs.mcp-servers-nix.flakeModule
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

    mcp-servers = {
      programs = {
        nixos.enable = true;
      };

      flavors = {
        claude-code.enable = true;
        opencode.enable = true;
      };
    };

    devShells.default = pkgs.mkShell {
      name = "dotfiles-shell";
      meta.description = "Shell environment for modifying this Nix configuration";
      packages = with pkgs;
        [
          just
          nh
          pre-commit
        ]
        ++ config.pre-commit.settings.enabledPackages
        ++ config.mcp-servers.packages;

      shellHook = ''
        ${config.pre-commit.installationScript}
        ${config.mcp-servers.shellHook}
      '';
    };
  };
}
