{
  flake,
  pkgs,
  ...
}: {
  imports = [flake.inputs.niri.nixosModules.niri];

  programs.niri.enable = true;
  # Pinned stable supports these settings, virtual keyboards and native XWayland.
  programs.niri.package = flake.inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable;
}
