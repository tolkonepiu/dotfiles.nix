{
  description = "Configuration for MacOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
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
  };

  nixConfig = {
    extra-trusted-public-keys = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    extra-substituters = "https://nix-community.cachix.org";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
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

    forEachSystem = nixpkgs.lib.genAttrs (import systems);
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
    packages = forEachSystem (system: {
      devenv-up = self.devShells.${system}.default.config.procfileScript;
      devenv-test = self.devShells.${system}.default.config.test;
    });

    devShells =
      forEachSystem
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = inputs.devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              enterTest = ''
                nh darwin build --hostname "${system}" --no-nom . -- --accept-flake-config
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
