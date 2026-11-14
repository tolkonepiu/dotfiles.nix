let
  root = "/games/rom-library";
in {
  inherit root;
  roms = "${root}/roms";
  bios = "${root}/bios";
}
