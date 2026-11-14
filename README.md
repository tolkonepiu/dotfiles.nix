<!-- markdownlint-disable -->
<h1 align="center">
	<img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/logo/nix-snowflake-colours.svg" width="150" alt="Logo"/><br/>
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
	dotfiles.nix
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
</h1>

<p align="center">
  My personal Nix configuration for macOS, Steam Deck, and a headless NixOS agent server.
</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</p>

<div align="center">
<img src="https://img.shields.io/github/actions/workflow/status/tolkonepiu/dotfiles.nix/build.yml?branch=main&style=for-the-badge&labelColor=45475a&label=build"/>&nbsp;
<img src="https://img.shields.io/github/actions/workflow/status/tolkonepiu/dotfiles.nix/tests.yml?branch=main&style=for-the-badge&labelColor=45475a&label=tests"/>

</div>
<!-- markdownlint-enable -->

## Hosts

| Host | Configuration | Platform | Role |
| --- | --- | --- | --- |
| MacBook Pro M4 Pro | [`chch-mbp-m4pro`](configurations/darwin/chch-mbp-m4pro.nix) | macOS · `aarch64-darwin` | Daily driver and development |
| Steam Deck | [`chch-deck`](configurations/nixos/chch-deck) | NixOS · `x86_64-linux` | Handheld gaming and desktop |
| Agent server | [`chch-agent-server`](configurations/nixos/chch-agent-server) | NixOS · `x86_64-linux` | Headless AI agents and development |

## Features

- **Zsh configuration**: Custom shell setup with my
  [zdotdir](https://github.com/tolkonepiu/zdotdir) configuration and
  Antidote plugin management.
- **Catppuccin theme**: Consistent
  [Catppuccin](https://github.com/catppuccin/catppuccin) Mocha theming
  across the shell, editor, and desktop applications.
- **Firefox configuration**: Privacy-focused setup with
  [Betterfox](https://github.com/yokoffing/Betterfox) optimizations and
  declaratively managed extensions.
- **Multi-agent OpenCode**: [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim/)
  orchestrates specialist agents with dedicated models, tools, and skills;
  [Hindsight](https://github.com/vectorize-io/hindsight) adds persistent
  coding-agent memory. The same setup runs locally and on the headless server.
- **Shared MCP configuration**: OpenCode, Codex, and Claude Code use the same
  GitHub, Context7, and headless Playwright servers instead of separate
  per-client definitions.
- **Scrollable tiling**: [Paneru](https://github.com/karinushka/paneru) with
  Vim-style window navigation, virtual workspaces, and continuous
  three-finger trackpad gestures.
- **Secretive SSH agent**: SSH uses
  [Secretive](https://github.com/maxgoedjen/secretive)'s agent socket rather
  than the default agent.
- **Gaming ↔ desktop**: Jovian boots into Steam with Decky Loader, while
  desktop mode runs [niri](https://github.com/niri-wm/niri) and
  [Noctalia](https://github.com/noctalia-dev/noctalia). A custom session action
  returns directly to Gaming Mode.
- **Gamepad-controlled Wayland desktop**: Steam Input keyboard and mouse
  emulation via `extest` lets the Deck's controls drive the desktop.
- **NixOS updates in the shell**: A custom Noctalia plugin checks this
  repository's `main` branch, installs updates, and reports when a reboot is
  needed. Scheduled updates use the same system service; reboots stay manual.
