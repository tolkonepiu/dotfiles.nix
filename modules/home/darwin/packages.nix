{pkgs, ...}: {
  home.packages = with pkgs; [
    # Development tools
    ast-grep
    biome
    devenv
    docker
    docker-compose
    kubectl
    markdownlint-cli
    nixd
    shellcheck
    shfmt
    yaml-language-server
    yamllint

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

    # Virtualization
    colima
    lima-full

    # Tools
    mole-cleaner
  ];
}
