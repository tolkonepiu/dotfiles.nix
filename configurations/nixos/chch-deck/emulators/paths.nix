let
  root = "/games/romm-library";
  saves = "${root}/saves";
in {
  inherit root saves;
  bios = "${root}/bios";
  states = "${saves}/states";
}
