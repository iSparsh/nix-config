{
  description = "Personal dendritic NixOS configurations with Hjem";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    dux-shell.url = "github:duxlabs-dev/dux-shell/stable";
    dux-search.url = "github:duxlabs-dev/dux-search/v2.1.1";
    dux-files.url = "github:duxlabs-dev/dux-files/v2.1.2";
    dux-greeter.url = "github:duxlabs-dev/dux-greeter/v2.1.2";
    hex.url = "github:anomalyco/hex/v3.4.0";
    herdr.url = "github:herdrdev/herdr-nix";
    opencode.url = "github:anomalyco/opencode/v2.2.7";
    zed.url = "github:zed-industries/zed/v1.28.1";
    artcraft.url = "github:Hy4ri/artcraft-flake";
    artcraft-launcher.url = "github:storytold/craft-launcher/v0.19.2";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        imports = [
          inputs.flake-parts.flakeModules.modules
        ]
        ++ builtins.filter (lib.hasSuffix ".mod.nix") (lib.filesystem.listFilesRecursive ./.);
      }
    );
}
