let
  root = "/games/romm-library";
  saves = "${root}/saves";
in {
  inherit root saves;
  bios = "${root}/bios";
  roms = "${root}/roms";
  states = "${saves}/states";
}
