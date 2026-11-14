let
  root = "/games/rom-library";
in {
  inherit root;
  bios = "${root}/bios";
  roms = "${root}/roms";
}
