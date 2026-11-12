{ inputs, ... }:
{
  flake.modules.nixos.artcraft =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      environment.systemPackages = [
        inputs.artcraft-launcher.packages.${system}.default
        inputs.artcraft.packages.${system}.wordcraft
        inputs.artcraft.packages.${system}.pdfcraft
      ];
    };
}
