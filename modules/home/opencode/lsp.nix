{
  lib,
  pkgs,
  ...
}: {
  programs.opencode.settings.lsp = {
    json = {
      command = [
        "${lib.getExe' pkgs.vscode-langservers-extracted "vscode-json-language-server"}"
        "--stdio"
      ];
      extensions = [".json" ".jsonc" ".json5"];
    };
    markdown = {
      command = [
        "${lib.getExe pkgs.marksman}"
        "server"
      ];
      extensions = [".md" ".mdx"];
    };
  };
}
