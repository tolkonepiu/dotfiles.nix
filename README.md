<!-- markdownlint-disable -->
<h1 align="center">
	<img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/logo/nix-snowflake-colours.svg" width="150" alt="Logo"/><br/>
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
	dotfiles.nix
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
</h1>

<p align="center">
  My personal configuration for macOS and NixOS (Steam Deck).
</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</p>

<div align="center">
<img src="https://img.shields.io/badge/26.11-informational.svg?style=for-the-badge&logo=nixos&logoColor=white&color=cba6f7&labelColor=45475a"/>&nbsp;
<img src="https://img.shields.io/github/actions/workflow/status/tolkonepiu/dotfiles.nix/build.yml?branch=main&style=for-the-badge&labelColor=45475a&label=build"/>&nbsp;
<img src="https://img.shields.io/github/actions/workflow/status/tolkonepiu/dotfiles.nix/tests.yml?branch=main&style=for-the-badge&labelColor=45475a&label=tests"/>

</div>
<!-- markdownlint-enable -->

## Features

### Shared

- **Advanced Shell Configuration**: Custom ZSH setup with my
  [zdotdir](https://github.com/tolkonepiu/zdotdir) configuration
- **Modern CLI Tools**: Leveraging tools like `atuin`, `eza`, `fd`, `zoxide`,
  `bat` and others for an efficient command-line experience
- **Catppuccin Theme**: Consistent
  [Catppuccin](https://github.com/catppuccin/catppuccin) 🌿 Mocha flavor theming
  across all applications
- **Firefox Configuration**: Privacy-focused setup with
  [Betterfox](https://github.com/yokoffing/Betterfox) optimizations and
  extension management
- **Git**: Signed commits, LFS support, and the
  [delta](https://github.com/dandavison/delta) diff viewer

### macOS

- **Window Management**: [Paneru](https://github.com/karinushka/paneru) with
  keyboard bindings and trackpad gestures
- **Touch ID & Apple Watch for sudo**: Use fingerprint or Apple Watch
  authentication instead of typing passwords for sudo commands
- **Homebrew and Mac App Store Integration**: Manages macOS applications via
  Homebrew casks and Mac App Store
- **Secretive Integration**: Secure SSH key management with
  [Apple's Secure Enclave](https://popov.wtf/secure-ssh-keys-with-secure-enclave-on-macos)
- **Kubernetes & Containers**: `kubectl` with [krew](https://krew.sigs.k8s.io/)
  plugin management, Docker CLI and Compose,
  [Colima](https://github.com/abiosoft/colima), and Lima
- **Dev Environment**: [direnv](https://direnv.net/) with nix-direnv,
  [devenv](https://devenv.sh/), and Rust, Python, and Node.js toolchains
- **Neovim**: Declarative editor config built on
  [nvf](https://github.com/NotAShelf/nvf) with LSP, Treesitter, and
  multi-language support (Nix, Rust, TypeScript, Python, and more)
- **OpenCode**: AI-powered terminal IDE via [OpenCode](https://opencode.dev/)
  with
  [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim/)
  multi-agent orchestration, MCP servers, plugins, and skills
- **Spicetify Spotify**: Custom Spotify theming with Catppuccin colors and
  useful extensions with the help of [Spicetify](https://spicetify.app/)

### Steam Deck

- **Gaming Mode**: Jovian NixOS starts Steam automatically, with Decky Loader
  enabled and a separate desktop session
- **Desktop Mode**: [niri](https://github.com/niri-wm/niri) with
  [Noctalia](https://github.com/noctalia-dev/noctalia) for the bar, launcher,
  system controls, and NixOS update status, with desktop control via the
  Steam Deck gamepad using Steam Input
- **Hardware Support**: Steam-controlled TDP and GPU clocks, software fan
  control, and BIOS/controller firmware updates restricted to external power
- **Memory & SSD**: Zstd-compressed zram swap and periodic SSD trimming
- **System Updates**: Scheduled updates from this repository's `main` branch
  and manual updates through Noctalia, without automatic reboots
