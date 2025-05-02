# Shared Modules

This directory contains platform-agnostic configurations that are shared across
different systems. These modules define the base configurations that can be
extended by platform-specific modules.

## Overview

The shared modules provide:

- Common user environment configurations
- Application settings that work across platforms
- Base configurations that platform-specific modules can extend

Much of the core configuration for both macOS and potential future platforms
(like NixOS) is defined here to ensure consistency and reduce duplication.

## Directory Structure

```sh
.
├── home-manager/           # User environment configurations
├── default.nix             # Main shared module definition
├── files.nix               # Static configuration files
├── home-manager.nix        # Home Manager module integration
└── packages.nix            # Common packages for all platforms
```

## Design Philosophy

These modules follow these design principles:

1. **Platform Agnostic**: No platform-specific logic in shared modules
2. **Extensible**: Designed to be easily extended by platform-specific modules
3. **Modular**: Each application has its own configuration file
4. **DRY**: Don't Repeat Yourself - common configurations in one place

## Home Manager Module

The `home-manager` directory contains individual configuration files for each
application or tool managed by Home Manager. Each of these files can be extended
by platform-specific modules.

For details on how platform-specific modules extend these shared configurations,
see the [Darwin home-manager README](../darwin/home-manager/README.md).
