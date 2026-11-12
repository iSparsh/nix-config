{
  flake.modules.nixos.appearance =
    { pkgsLatest, ... }:
    let
      pins = builtins.fromJSON (builtins.readFile ../../packages.json);
      ioskeley = pkgsLatest.stdenvNoCC.mkDerivation {
        pname = "ioskeley-mono-term-nerd-font";
        inherit (pins.ioskeley) version;
        src = pkgsLatest.fetchurl { inherit (pins.ioskeley) url hash; };
        nativeBuildInputs = [ pkgsLatest.unzip ];
        dontUnpack = true;
        installPhase = ''
          mkdir -p "$out/share/fonts/truetype"
          unzip -j "$src" 'Normal/*.ttf' -d "$out/share/fonts/truetype"
        '';
        meta.license = pkgsLatest.lib.licenses.ofl;
      };
      appleEmoji = pkgsLatest.stdenvNoCC.mkDerivation {
        pname = "apple-color-emoji";
        inherit (pins.apple-emoji) version;
        src = pkgsLatest.fetchurl { inherit (pins.apple-emoji) url hash; };
        dontUnpack = true;
        installPhase = ''install -Dm644 "$src" "$out/share/fonts/truetype/AppleColorEmoji.ttf"'';
        meta.license = pkgsLatest.lib.licenses.unfree;
      };
    in
    {
      local.allowedUnfreePackages = [ "apple-color-emoji" ];

      fonts = {
        enableDefaultPackages = true;
        packages = with pkgsLatest; [
          ioskeley
          appleEmoji
          nerd-fonts.jetbrains-mono
          inter
          source-serif-pro
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
        ];
        fontconfig = {
          enable = true;
          defaultFonts = {
            monospace = [
              "IoskeleyMonoTerm Nerd Font Mono"
              "JetBrainsMono Nerd Font Mono"
            ];
            sansSerif = [ "Inter" ];
            serif = [ "Source Serif Pro" ];
            emoji = [
              "Apple Color Emoji"
              "Noto Color Emoji"
            ];
          };
        };
      };
    };
}
