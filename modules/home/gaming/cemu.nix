{flake, ...}: {
  imports = [flake.inputs.nix-emulators.homeManagerModules.cemu];

  programs.cemu = {
    enable = true;
    # Use Cemu's default MLC and save locations.
    settings.Audio = {
      api = 3;
      TVChannels = 1;
      TVVolume = 50;
      TVDevice = "default";
    };
  };
}
