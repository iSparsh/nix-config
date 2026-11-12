{ config, inputs, ... }:
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  perSystem =
    { pkgs, ... }:
    let
      # Evaluate shared integration without inventing a deployable host.
      base = inputs.nixpkgs.lib.nixosSystem {
        system = pkgs.stdenv.hostPlatform.system;
        modules = [ config.flake.modules.nixos.base ];
      };
    in
    {
      formatter = pkgs.nixfmt-tree;

      checks.base-integration =
        assert builtins.elem "flakes" base.config.nix.settings.experimental-features;
        assert builtins.elem "nix-command" base.config.nix.settings.experimental-features;
        assert base.config.hjem.users == { };
        pkgs.runCommand "base-integration" { } ''
          touch "$out"
        '';
    };
}
