{
  flake.modules.nixos.base =
    { config, lib, ... }:
    {
      options.local.allowedUnfreePackages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Unfree package names explicitly allowed by selected profiles.";
      };

      config.nixpkgs.config.allowUnfreePredicate =
        package: builtins.elem (lib.getName package) config.local.allowedUnfreePackages;
    };
}
