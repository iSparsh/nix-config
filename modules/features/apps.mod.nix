{ inputs, ... }:
{
  flake.modules.nixos.apps =
    { pkgsLatest, ... }:
    {
      environment.systemPackages =
        with pkgsLatest;
        [
          chromium
          gh
          neovim
          foot
          obsidian
          mpv
          vlc
          bitwarden-cli
          bitwarden-desktop
          gnome-calculator
        ]
        ++ [ inputs.zed.packages.${pkgsLatest.stdenv.hostPlatform.system}.default ];

      local.allowedUnfreePackages = [ "obsidian" ];
    };
}
