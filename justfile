# Like GNU `make`, but `just` rustier.
# https://just.systems/
# run `just` from this directory to see available commands

# Default command when 'just' is run without arguments
default:
  @just --list

# Update nix flake
[group('Main')]
update:
  nix flake update

# Format nix files
[group('dev')]
lint:
  nix fmt .

# Check nix flake and run pre-commit checks
[group('dev')]
check:
  nix flake check

# Manually enter dev shell
[group('dev')]
dev:
  nix develop

# Build the configuration
[group('Main')]
build:
  nh darwin build .

# Activate the configuration
[group('Main')]
switch:
  nh darwin switch .
