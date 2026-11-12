{

  config,
  inputs,
  lib,
  ...
}:
{
  options.fleet.sharedProfiles = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [
      "shell"
      "desktop"
      "apps"
      "development"
      "ai-tools"
      "appearance"
      "connectivity"
      "artcraft"
    ];
    description = "Shared profiles selected by default on installed hosts.";
  };

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
            default = config.fleet.sharedProfiles;
            description = "Additional names from flake.modules.nixos; base is always included.";
          };

          primaryUser = lib.mkOption {
            type = lib.types.str;
            description = "Existing normal user from the machine's installation.";
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
        {
          networking.hostName = name;
          local.primaryUser = host.primaryUser;
        }
      ]
      ++ map (
        profile:
        config.flake.modules.nixos.${profile}
          or (throw "nix-config: host '${name}' selects unknown profile '${profile}'")
      ) host.profiles;
    }
  ) config.fleet.hosts;
}
