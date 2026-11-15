{
  profiles = {
    handheld-battery = {
      game = {
        width = 1280;
        height = 800;
      };
      output = {
        width = 1280;
        height = 800;
        hz = 60;
      };
      filter = "linear";
      watts = 12;
    };
    handheld-ac = {
      game = {
        width = 1280;
        height = 800;
      };
      output = {
        width = 1280;
        height = 800;
        hz = 60;
      };
      filter = "linear";
      watts = 15;
    };
    external-battery = {
      game = {
        width = 1600;
        height = 900;
      };
      output = {
        width = 3840;
        height = 2160;
        hz = 60;
      };
      filter = "fsr";
      watts = 12;
    };
    external-ac = {
      game = {
        width = 1600;
        height = 900;
      };
      output = {
        width = 3840;
        height = 2160;
        hz = 60;
      };
      filter = "fsr";
      watts = 15;
    };
  };
  games = {};
}
