{pkgs, ...}: {
  # Nix packages to install to $HOME
  #
  # Search for packages here: https://search.nixos.org/packages
  home.packages = with pkgs; [
    # System tools
    curl
    fastfetch
    ripgrep
    watch
    wget

    # Encryption and security tools
    age
    gopass
    sops
  ];

  # Programs natively supported by home-manager.
  # They can be configured in `programs.*` instead of using home.packages.
  programs = {
    # Better `cat`
    bat.enable = true;
    jq.enable = true;
  };
}
