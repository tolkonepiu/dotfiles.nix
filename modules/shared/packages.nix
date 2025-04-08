{ pkgs }:

with pkgs; [
  # General packages for development and system management
  fastfetch

  # Encryption and security tools
  gnupg
  gopass

  # Python packages
  python3
  virtualenv

  # Terminal utilities
  antidote
  autojump

  # Fonts
  meslo-lgs-nf
]
