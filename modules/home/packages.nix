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
      ast-grep
      biome
      cursor-cli
      devenv
      docker
      kubectl
      markdownlint-cli
      nixd
      shellcheck
      shfmt
      yaml-language-server
      yamllint

      # Encryption and security tools
      age
      gnupg
      gopass
      sops

      # Python packages
      pipx
      pyright
      python3
      virtualenv

      # Web development tools
      bun
      nodejs

      # Rust packages
      cargo
      clippy
      rust-analyzer
      rustc
      rustfmt

      # Terminal utilities
      wakatime-cli

      # Fonts
      nerd-fonts.departure-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
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
