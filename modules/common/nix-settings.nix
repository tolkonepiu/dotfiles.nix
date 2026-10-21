{
  lib,
  pkgs,
  ...
}: {
  nix.settings = {
    # let the system decide the number of max jobs
    max-jobs = "auto";
    cores = 0;

    allowed-users = ["*"];

    # Root and configured users are trusted by myusers.nix.
    trusted-users = lib.optionals pkgs.stdenv.hostPlatform.isDarwin ["@admin"];

    # build inside sandboxed environments
    sandbox = true;
    sandbox-fallback = false;

    # continue building derivations if one fails
    keep-going = true;

    # If we haven't received data for >= 20s, retry the download
    stalled-download-timeout = 20;

    # bail early on missing cache hits
    connect-timeout = 5;

    # show more log lines for failed builds
    log-lines = 30;

    # Enable the CLI and flakes alongside supported experimental features.
    extra-experimental-features = [
      "nix-command"
      "flakes"
      "parse-toml-timestamps"
      "pipe-operators"
      "blake3-hashes"
      "verified-fetches"
      "fetch-tree"
      "git-hashing"
    ];

    # don't warn that my git tree is dirty it is known through git
    warn-dirty = false;

    # maximum number of parallel TCP connections used to fetch imports and binary caches, 0 means no limit
    http-connections = 35;

    # use nix-community Cachix for community-maintained packages
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://tolkonepiu.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "tolkonepiu.cachix.org-1:G7pWK5VSW/AkjiZ737/lPVQjOvK4bMcMYZaSJiW5pHQ="
    ];

    # Whether to accept nix configuration from a flake without displaying a Y/N prompt.
    accept-flake-config = false;

    # for direnv GC roots
    keep-derivations = true;
    keep-outputs = true;

    # use binary cache, this is not gentoo
    builders-use-substitutes = true;
  };
}
