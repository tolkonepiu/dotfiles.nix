# macOS Nix Configuration

This repository contains my personal macOS configuration using Nix,
[nix-darwin](https://github.com/nix-darwin/nix-darwin), and
[home-manager](https://github.com/nix-community/home-manager). It follows a
modular approach to managing system and user configurations. This configuration
was inspired by
[dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config).

## Structure

The repository is organized into these main directories:

```sh
.
├── apps/              # Executable scripts for building and managing the system
├── hosts/             # Host-specific configurations
└── modules/           # Modular configuration components
    ├── darwin/        # macOS-specific modules
    └── shared/        # Platform-agnostic modules
```

## Features

- **Modular Design**: Clear separation between shared and platform-specific
  configurations
- **Centralized User Configuration**: Personal details defined once in flake.nix and referenced throughout
- **Declarative System Configuration**: Complete system setup declared in code
- **Homebrew Integration**: Manages macOS applications via Homebrew casks
- **Dock Configuration**: Declarative macOS dock setup
- **Reproducible Environment**: Consistent development environment

## Usage

> [!IMPORTANT]
>
> This configuration contains many of my personal details (e.g. in Git, SSH, and
> other user-specific settings). It is **not recommended** to apply it as-is.  
> Instead, use this repository as a reference or source of inspiration for
> building your own setup.

### Customizing User Information

To use this configuration with your own personal details, modify the `userConfig` object in `flake.nix`:

```nix
# In flake.nix
userConfig = {
  name = "Your Name";
  email = "your.email@example.com";
  username = "yourusername";
};
```

This centralized approach ensures your personal information is defined in one place and referenced throughout the configuration.

### Initial Setup

If you're setting up a new macOS system:

```bash
# Install Nix (Determinate Nix)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Build and switch to the configuration
nix run .#build-switch
```

> [!IMPORTANT]
>
> The installer will ask if you want to install Determinate Nix. Answer _No_ as
> it
> [currently conflicts](https://github.com/dustinlyons/nixos-config/issues/146)
> with `nix-darwin`.

### Managing Configuration

```bash
# Update and rebuild configuration
nix run .#build

# Apply configuration changes
nix run .#build-switch

# Rollback to previous generation
nix run .#rollback
```

## Modules

Refer to individual module READMEs for more details:

- [Shared Modules](./modules/shared/README.md) - Platform-agnostic
  configurations
- [Darwin Modules](./modules/darwin/README.md) - macOS-specific configurations

## License

This project is personal configuration code. Feel free to use it for
inspiration, but it's designed specifically for my needs and workflow.
