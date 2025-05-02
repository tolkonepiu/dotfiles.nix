# Darwin (macOS) Home Manager Modules

This directory contains macOS-specific Home Manager modules that extend or
override the shared modules.

## Module Structure

Each module in this directory corresponds to a module with the same name in the
shared [home-manager directory](../../shared/home-manager/). This parallel
structure allows for clear organization and easy navigation between shared and
platform-specific configurations.

## Extension Pattern

Rather than duplicating configuration, these modules only specify the
macOS-specific additions or overrides. The Nix module system handles merging
these with the shared settings automatically.

### Example

If the shared git module has:

```nix
# in modules/shared/home-manager/git.nix
{
  programs.git = {
    enable = true;
    ignores = [ "*.swp" ];
    # ... other shared git settings
  };
}
```

The Darwin-specific module might have:

```nix
# in modules/darwin/home-manager/git.nix
{
  programs.git.ignores = [ ".DS_Store" ]; # Only specify macOS additions
}
```

When both are imported, Nix merges them to create:

```nix
{
  programs.git = {
    enable = true;
    ignores = [ "*.swp" ".DS_Store" ];
    # ... other shared git settings
  };
}
```

## Adding New Modules

To add a new Darwin-specific module:

1. Create a new file in this directory (e.g., `newmodule.nix`)
2. Add macOS-specific settings only (leave shared settings in the shared module)
3. Add the module to the imports in `default.nix`

## Integration

The `default.nix` file in this directory imports both:

1. The shared home-manager modules (for base configuration)
2. The Darwin-specific modules in this directory (for macOS customizations)
