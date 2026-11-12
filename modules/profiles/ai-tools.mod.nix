{
  flake.modules.nixos.ai-tools =
    { pkgs, ... }:
    {
      # These two CLIs deliberately use Nixpkgs, as requested by the owner.
      environment.systemPackages = [
        pkgs.codex
        pkgs.claude-code
      ];

      local.allowedUnfreePackages = [ "claude-code" ];
    };
}
