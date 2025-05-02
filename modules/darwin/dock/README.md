# macOS Dock Configuration Module

This module provides declarative configuration for the macOS Dock, allowing you
to define exactly which applications appear in the Dock and in what order.

## Overview

The Dock module:

- Completely manages the macOS Dock layout
- Adds applications in a specified order
- Groups items into sections
- Only rebuilds the Dock when changes are detected

## Usage

To use this module, configure the `local.dock` options in your Nix
configuration:

```nix
local.dock.enable = true;
local.dock.entries = [
  { path = "/System/Applications/Launchpad.app"; }
  { path = "/Applications/Arc.app"; }
  { path = "/Applications/Visual Studio Code.app"; }
  # Add more applications as needed
];
```

## Options

### `local.dock.enable`

Enables or disables the Dock management. Defaults to true on Darwin systems.

### `local.dock.entries`

A list of attribute sets representing applications to add to the Dock. Each
entry can have:

- `path`: Path to the application (required)
- `section`: Section to add the app to (default: "apps")
- `options`: Additional options to pass to dockutil (default: "")

## Implementation

This module uses [dockutil](https://github.com/kcrawford/dockutil) to manage the
Dock. It:

1. Compares the current Dock with the desired configuration
2. Only rebuilds the Dock when changes are detected
3. Uses activation scripts to apply changes during system activation

## Credits

This module is based on a
[gist by antifuchs](https://gist.github.com/antifuchs/10138c4d838a63c0a05e725ccd7bccdd)
with modifications for this configuration system.
