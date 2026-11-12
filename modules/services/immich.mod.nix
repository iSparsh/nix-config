{
  flake.modules.nixos.server = { pkgsLatest, ... }: {
    services.immich = {
      enable = true;
      package = pkgsLatest.immich;
      host = "0.0.0.0";
      port = 2283;
      openFirewall = true;
      mediaLocation = "/var/lib/immich";
      database.enable = true;
      redis.enable = true;
      machine-learning.enable = true;
    };

    services.postgresql.package = pkgsLatest.postgresql_17;
  };
}
