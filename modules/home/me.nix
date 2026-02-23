# User configuration module
{
  lib,
  config,
  ...
}: {
  options = {
    me = {
      username = lib.mkOption {
        type = lib.types.str;
        description = "Your username as shown by `id -un`";
      };
      fullname = lib.mkOption {
        type = lib.types.str;
        description = "Your full name for use in Git config";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "Your email for use in Git config";
      };
      atuinServer = lib.mkOption {
        type = lib.types.str;
        default = "https://api.atuin.sh";
        description = "Atuin server address (e.g., https://atuin.example.com)";
      };
    };
  };
  config = {
    home.username = config.me.username;
  };
}
