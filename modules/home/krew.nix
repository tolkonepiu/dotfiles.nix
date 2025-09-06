{
  pkgs,
  flake,
  ...
}: let
  inherit (flake) inputs;
in {
  imports = [inputs.krewfile.homeManagerModules.krewfile];

  programs.krewfile = {
    enable = true;
    krewPackage = pkgs.krew;
    indexes = {
      default = "https://github.com/kubernetes-sigs/krew-index.git";
      netshoot = "https://github.com/nilic/kubectl-netshoot.git";
    };
    plugins = [
      "krew"
      "netshoot/netshoot"
    ];
  };
}
