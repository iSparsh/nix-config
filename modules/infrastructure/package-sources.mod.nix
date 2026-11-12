{ inputs, ... }:
{
  flake.modules.nixos.base =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.local.primaryUser = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Existing installed user receiving the shared home configuration.";
      };

      config._module.args.pkgsLatest = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfreePredicate = config.nixpkgs.config.allowUnfreePredicate;
      };

      config.hjem.users = lib.optionalAttrs (config.local.primaryUser != null) {
        ${config.local.primaryUser} = {
          user = config.local.primaryUser;
          directory = config.users.users.${config.local.primaryUser}.home;
        };
      };
    };
}
