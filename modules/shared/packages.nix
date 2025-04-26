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
  gnupg
  gopass

  # Python packages
  python3
  virtualenv

  # Terminal utilities
  antidote
  autojump
  direnv
  gum
  wakatime-cli

  # Fonts
  meslo-lgs-nf
]
