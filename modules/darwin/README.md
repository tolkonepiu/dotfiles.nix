
# Darwin (macOS) Modules

This directory contains configuration modules specific to macOS (Darwin) systems. These modules integrate with the shared configuration and add macOS-specific functionality.

## Overview

The Darwin modules handle:

- macOS-specific system settings
- Homebrew package and cask management
- MacOS Dock configuration
- Platform-specific overrides for shared configurations

## Directory Structure

```
.
├── dock/               # MacOS dock configuration module
│   └── default.nix     # Dock settings and application list
├── home-manager/       # Darwin-specific home-manager configs
│   ├── default.nix     # Imports shared and Darwin-specific modules
│   ├── git.nix         # Git extensions for macOS
│   ├── ssh.nix         # SSH extensions for macOS
│   └── README.md       # Documentation for Darwin home-manager modules
├── casks.nix           # List of Homebrew casks to install
├── default.nix         # Main Darwin module definition
├── files.nix           # Static configuration files for macOS
├── home-manager.nix    # User and home-manager configuration
└── packages.nix        # Darwin-specific packages
```

## Module Integration

The Darwin configuration extends shared configurations by:

1. Importing shared modules as a base
2. Adding macOS-specific settings and overrides
3. Using the Nix module system to merge configurations automatically

See the [home-manager module README](./home-manager/README.md) for details on how the Darwin-specific home-manager modules extend shared configurations.

## Usage

This module is automatically imported by the host configuration in `hosts/darwin/default.nix` and should not need to be imported directly in most cases.

For development patterns and implementation details, see the [GitHub instructions](../../.github/instructions/module-specific-guide.md).
