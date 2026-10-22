# Like GNU `make`, but `just` rustier.
# https://just.systems/
# run `just` from this directory to see available commands

nh_system := if os() == "macos" {
  "darwin"
} else if os() == "linux" {
  "os"
} else {
  error("Unsupported operating system: " + os())
}

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
  nh {{nh_system}} build .

# Activate the configuration
[group('Main')]
switch:
  nh {{nh_system}} switch . --show-activation-logs
