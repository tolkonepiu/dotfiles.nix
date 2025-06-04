{ pkgs }:

with pkgs;
[
  # System monitoring and performance tools
  fastfetch
  htop

  # Nix ecosystem tools
  nix-direnv
  nixfmt-rfc-style

  # Development tools
  kubectl

  # Encryption and security tools
  age
  gnupg
  gopass
  sops

  # Python packages
  pipx
  python3
  virtualenv

  # Node.js development tools
  nodejs

  # Terminal utilities
  antidote
  autojump
  direnv
  gum
  uv
  wakatime-cli

  # Fonts
  meslo-lgs-nf

  # Web and browsing
  firefox-devedition
]
