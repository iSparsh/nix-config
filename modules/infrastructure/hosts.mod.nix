{
  config,
  inputs,
  lib,
  ...
}:
{
  options.fleet.hosts = lib.mkOption {
    default = { };
    description = "Installed machines and their selected NixOS profiles.";
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          system = lib.mkOption {
            type = lib.types.enum [
              "x86_64-linux"
              "aarch64-linux"
            ];
            description = "The machine's architecture.";
          };

          profiles = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Additional names from flake.modules.nixos; base is always included.";
          };

          module = lib.mkOption {
            type = lib.types.deferredModule;
            description = "Host-local settings and supporting hardware imports.";
          };
        };
      }
    );
  };

  config.flake.nixosConfigurations = lib.mapAttrs (
    name: host:
    inputs.nixpkgs.lib.nixosSystem {
      system = host.system;
      modules = [
        config.flake.modules.nixos.base
        host.module
        { networking.hostName = name; }
      ]
      ++ map (
        profile:
        config.flake.modules.nixos.${profile}
          or (throw "nix-config: host '${name}' selects unknown profile '${profile}'")
      ) host.profiles;
    }
  ) config.fleet.hosts;
}
