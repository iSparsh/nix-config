{
  description = "Personal dendritic NixOS configurations with Hjem";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

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
