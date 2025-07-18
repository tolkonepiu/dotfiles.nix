{
  description = "Configuration for MacOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    zdotdir = {
      url = "github:tolkonepiu/zdotdir";
      flake = false;
    };

    betterfox = {
      url = "github:yokoffing/betterfox";
      flake = false;
    };

    ctp-delta = {
      url = "github:catppuccin/delta";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    userConfig = {
      name = "Pavel Popov";
      email = "me@popov.wtf";
      username = "chchmthrfckr";
    };
    darwinSystems = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    forAllSystems = f: nixpkgs.lib.genAttrs darwinSystems f;

    devShell = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = inputs.devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          {
            enterTest = ''
              nix flake check
            '';
            git-hooks.hooks = {
              alejandra.enable = true;
              check-yaml.enable = true;
              deadnix.enable = true;
              end-of-file-fixer.enable = true;
              gptcommit.enable = true;
              markdownlint.enable = true;
              shellcheck = {
                enable = true;
                excludes = [
                  "\\.envrc"
                ];
              };
              shfmt.enable = true;
              yamllint.enable = true;
            };
          }
        ];
      };
    };
    mkDarwinApp = scriptName: system: {
      type = "app";
      program = "${
        (nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
          PATH=${nixpkgs.legacyPackages.${system}.nh}/bin:$PATH
          PATH=${nixpkgs.legacyPackages.${system}.gum}/bin:$PATH
          exec ${self}/apps/darwin/${scriptName} ${system} "$@"
        '')
      }/bin/${scriptName}";
    };
    mkDarwinApps = system: {
      "build" = mkDarwinApp "build" system;
      "build-switch" = mkDarwinApp "build-switch" system;
      "rollback" = mkDarwinApp "rollback" system;
    };
  in {
    devShells = forAllSystems devShell;

    packages = forAllSystems (system: {
      devenv-up = (devShell system).default.config.procfileScript;
      devenv-test = (devShell system).default.config.test;
    });

    apps = nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

    darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (
      system:
        inputs.darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              userConfig
              ;
          };
          modules = [
            inputs.home-manager.darwinModules.home-manager
            inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                user = userConfig.username;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = inputs.homebrew-core;
                  "homebrew/homebrew-cask" = inputs.homebrew-cask;
                  "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./hosts/darwin
          ];
        }
    );
  };
}
