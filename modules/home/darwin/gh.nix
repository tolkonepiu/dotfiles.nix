{pkgs, ...}: {
  programs.gh = {
    enable = true;
    extensions = [
      pkgs.gh-notify
    ];
    settings = {
      git_protocol = "ssh";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
  };
}
