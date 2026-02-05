{
  lib,
  pkgs,
  ...
}: {
  # Nix packages to install to $HOME
  #
  # Search for packages here: https://search.nixos.org/packages
  home.packages = with pkgs;
    [
      # System tools
      fastfetch

      # Development tools
      cursor-cli
      devenv
      docker
      kubectl
      markdownlint-cli
      shellcheck
      shfmt
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
    ]
    ++ lib.optionals stdenv.isDarwin [
      # Virtualization
      colima
      lima
    ];

  # Programs natively supported by home-manager.
  # They can be configured in `programs.*` instead of using home.packages.
  programs = {
    # Better `cat`
    bat.enable = true;
    jq.enable = true;
  };
}
