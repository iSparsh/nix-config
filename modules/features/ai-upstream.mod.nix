{ inputs, ... }:
{
  flake.modules.nixos.ai-tools =
    { pkgs, pkgsLatest, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      llamaCli = pkgs.runCommand "llama-cpp-cli" { } ''
        mkdir -p "$out/bin"
        ln -s ${pkgsLatest.llama-cpp}/bin/llama-cli "$out/bin/llama-cli"
      '';
    in
    {
      imports = [ inputs.hex.nixosModules.default ];

      programs.hex.enable = true;

      environment.systemPackages = [
        pkgsLatest.t3code
        inputs.opencode.packages.${system}.opencode
        inputs.opencode.packages.${system}.opencode-desktop
        inputs.herdr.packages.${system}.default
        llamaCli
      ];
    };
}
