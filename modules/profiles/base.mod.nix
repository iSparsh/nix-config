{ inputs, ... }:
{
  flake.modules.nixos.base = {
    imports = [ inputs.hjem.nixosModules.default ];

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
