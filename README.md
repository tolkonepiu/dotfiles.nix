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
- **Advanced Shell Configuration**: Custom ZSH setup with
  [zdotdir](https://github.com/tolkonepiu/zdotdir) integration and Antidote
  plugin manager
- **Touch ID for sudo**: Use fingerprint authentication instead of typing
  passwords for sudo commands
- **Homebrew and Mac App Store Integration**: Manages macOS applications via
  Homebrew casks and Mac App Store
- **Secretive Integration**: Secure SSH key management with
  [Apple's Secure Enclave](https://popov.wtf/secure-ssh-keys-with-secure-enclave-on-macos)
  (Apple Silicon only)

## Usage

> [!IMPORTANT]
>
> This configuration contains many of my personal details (e.g. in Git, SSH, and
> other user-specific settings). It is **not recommended** to apply it as-is.  
> Instead, use this repository as a reference or source of inspiration for
> building your own setup.

### Customizing User Information

To use this configuration with your own personal details, modify the
`userConfig` object in `flake.nix`:

```nix
# In flake.nix
userConfig = {
  name = "Your Name";
  email = "your.email@example.com";
  username = "yourusername";
};
```

This centralized approach ensures your personal information is defined in one
place and referenced throughout the configuration.

### Initial Setup

If you're setting up a new macOS system:

<!-- markdownlint-disable line-length -->

Install Nix (Determinate Nix):

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
```

<!-- markdownlint-enable line-length -->

Make [apps](./apps) executable:

<!-- markdownlint-disable line-length -->

```sh
find apps/darwin -type f \( -name build -o -name build-switch -o -name rollback \) -exec chmod +x {} \;
```

<!-- markdownlint-enable line-length -->

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
