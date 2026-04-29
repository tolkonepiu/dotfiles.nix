<!-- markdownlint-disable -->
<h1 align="center">
	<img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/logo/nix-snowflake-colours.svg" width="150" alt="Logo"/><br/>
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
	dotfiles.nix
	<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="30" width="0px"/>
</h1>

<p align="center">
  My personal macOS configuration using Nix,
  <a href="https://github.com/nix-darwin/nix-darwin">nix-darwin</a>, and
  <a href="https://github.com/nix-community/home-manager">home-manager</a>.
</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</p>

<div align="center">
<img src="https://img.shields.io/badge/26.05-informational.svg?style=for-the-badge&logo=nixos&logoColor=white&color=cba6f7&labelColor=45475a"/>&nbsp;
<img src="https://img.shields.io/github/actions/workflow/status/tolkonepiu/dotfiles/build.yml?branch=main&style=for-the-badge&labelColor=45475a&label=build"/>&nbsp;
<img src="https://img.shields.io/github/actions/workflow/status/tolkonepiu/dotfiles/tests.yml?branch=main&style=for-the-badge&labelColor=45475a&label=tests"/>

</div>
<!-- markdownlint-enable -->

## Features

- **Advanced Shell Configuration**: Custom ZSH setup with my
  [zdotdir](https://github.com/tolkonepiu/zdotdir) configuration
- **Modern CLI Tools**: Leveraging tools like `atuin`, `eza`, `fd`, `zoxide`,
  `bat` and others for an efficient command-line experience
- **Catppuccin Theme**: Consistent
  [Catppuccin](https://github.com/catppuccin/catppuccin) 🌿 Mocha flavor theming
  across all applications
- **Touch ID & Apple Watch for sudo**: Use fingerprint or Apple Watch
  authentication instead of typing passwords for sudo commands
- **Homebrew and Mac App Store Integration**: Manages macOS applications via
  Homebrew casks and Mac App Store
- **Secretive Integration**: Secure SSH key management with
  [Apple's Secure Enclave](https://popov.wtf/secure-ssh-keys-with-secure-enclave-on-macos)
- **Firefox Configuration**: Privacy-focused setup with
  [Betterfox](https://github.com/yokoffing/Betterfox) optimizations and
  extension management
- **Spicetify Spotify**: Custom Spotify theming with Catppuccin colors and
  useful extensions with the help of [Spicetify](https://spicetify.app/)
- **Git & GitHub CLI**: Signed commits,
  [delta](https://github.com/dandavison/delta) diff viewer, LFS support, and
  [gh](https://cli.github.com/) with extensions
- **Kubernetes & Containers**: `kubectl` with [krew](https://krew.sigs.k8s.io/)
  plugin management, Docker via [Colima](https://github.com/abiosoft/colima)
- **Dev Environment**: [direnv](https://direnv.net/) with nix-direnv,
  [devenv](https://devenv.sh/), and multi-language toolchains (Rust, Python,
  Node.js)
- **Neovim**: Declarative editor config built on
  [nvf](https://github.com/NotAShelf/nvf) with LSP, Treesitter, and
  multi-language support (Nix, Rust, TypeScript, Python, and more)
- **OpenCode**: AI-powered terminal IDE via [OpenCode](https://opencode.dev/)
  with
  [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim/)
  multi-agent orchestration, MCP servers, plugins, and skills
