# Shared Home Manager Modules

This directory contains platform-agnostic Home Manager configurations that serve
as the base for all systems. These modules define common settings that work
across platforms and can be extended by platform-specific modules.

## Overview

The shared Home Manager modules provide:

- Application configurations that work on any platform
- Common user environment settings
- Base configurations that platform-specific modules extend

## Module Structure

Each application or tool has its own dedicated configuration file:

```sh
.
├── bat.nix             # Bat (cat replacement) configuration
├── direnv.nix          # Direnv shell integration configuration
├── eza.nix             # Eza (ls replacement) configuration
├── fd.nix              # Fd (find replacement) configuration
├── firefox/            # Firefox configuration
├── git.nix             # Git version control configuration
├── ssh.nix             # SSH client configuration
├── zoxide.nix          # Zoxide (cd replacement) configuration
└── zsh.nix             # ZSH shell configuration
```

## Design Philosophy

These modules follow these key principles:

1. **Platform Independence**: No platform-specific logic should be present
2. **Single Responsibility**: Each file configures one tool or application
3. **Extensibility**: Settings are designed to be extended by platform modules
4. **Minimal Configuration**: Only essential configurations that apply
   everywhere

## Extension Mechanism

Platform-specific modules in directories like `../darwin/home-manager/` extend
these shared modules by:

1. Importing the shared modules first (via the default.nix)
2. Adding platform-specific overrides and additions
3. Using Nix's module system for automatic merging

For details on how platform-specific modules extend these configurations, see
the [Darwin home-manager README](../../darwin/home-manager/README.md).
