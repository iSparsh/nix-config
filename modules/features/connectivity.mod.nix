{
  flake.modules.nixos.connectivity = { pkgsLatest, ... }: {
    services.tailscale = {
      enable = true;
      package = pkgsLatest.tailscale;
      openFirewall = true;
    };
  };
}
