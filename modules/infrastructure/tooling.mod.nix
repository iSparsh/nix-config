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

      compatibilityLibraries = builtins.head (
        builtins.filter (package: package.name == "ld-library-path") base.config.environment.systemPackages
      );
    in
    {
      formatter = pkgs.nixfmt-tree;

      checks.base-integration =
        assert builtins.elem "flakes" base.config.nix.settings.experimental-features;
        assert builtins.elem "nix-command" base.config.nix.settings.experimental-features;
        assert base.config.hjem.users == { };
        assert base.config.programs.nix-ld.enable;
        pkgs.runCommand "base-integration" { inherit compatibilityLibraries; } ''
          # Check our additions and retained NixOS defaults in the actual library bundle.
          for library in libffi.so libsqlite3.so libglib-2.0.so libstdc++.so.6 libz.so; do
            test -e "$compatibilityLibraries/share/nix-ld/lib/$library"
          done

          touch "$out"
        '';
    };
}
