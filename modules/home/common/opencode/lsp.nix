{
  lib,
  pkgs,
  ...
}: {
  programs.opencode.settings.lsp = {
    markdown = {
      command = [
        "${lib.getExe pkgs.marksman}"
        "server"
      ];
      extensions = [".md" ".mdx"];
    };
  };
}
