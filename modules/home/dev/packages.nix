{pkgs, ...}: {
  home.packages = with pkgs; [
    # Development tools
    ast-grep
    biome
    devenv
    docker
    docker-compose
    kubectl
    paseo

    # Python packages
    pipx
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
  ];
}
