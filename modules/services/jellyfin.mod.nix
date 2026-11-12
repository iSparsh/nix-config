{
  flake.modules.nixos.server = { pkgsLatest, ... }: {
    services.jellyfin = {
      enable = true;
      package = pkgsLatest.jellyfin;
      openFirewall = true;
    };
  };
}
