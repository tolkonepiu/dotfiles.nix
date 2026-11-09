{
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = lib.mkDefault (
      if isDarwin
      then pkgs.pinentry_mac
      else pkgs.pinentry-curses
    );
  };
}
