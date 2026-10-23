{
  lib,
  osClass,
  ...
}: {
  imports =
    [./common]
    ++ lib.optionals (osClass == "darwin") [./darwin]
    ++ lib.optionals (osClass == "nixos") [./nixos];
}
