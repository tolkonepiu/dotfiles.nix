{pkgs, ...}: {
  # Nix packages to install to $HOME
  #
  # Search for packages here: https://search.nixos.org/packages
  home.packages = with pkgs; [
    # System monitoring and performance tools
    fastfetch
    htop

    # Development tools
    devenv
    kubectl
    markdownlint-cli
    shellcheck
    yamllint

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
    wakatime-cli

    # Fonts
    meslo-lgs-nf
  ];

  # Programs natively supported by home-manager.
  # They can be configured in `programs.*` instead of using home.packages.
  programs = {
    # Better `cat`
    bat.enable = true;
    jq.enable = true;
  };
}
