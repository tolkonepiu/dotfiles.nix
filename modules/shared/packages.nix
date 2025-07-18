{pkgs}:
with pkgs; [
  # System monitoring and performance tools
  fastfetch
  htop

  # Development tools
  devenv
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
  uv
  wakatime-cli

  # Fonts
  meslo-lgs-nf
]
