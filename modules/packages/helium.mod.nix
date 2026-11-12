{
  flake.modules.nixos.apps =
    { pkgsLatest, ... }:
    let
      system = pkgsLatest.stdenv.hostPlatform.system;
      release = (builtins.fromJSON (builtins.readFile ../../packages.json)).helium;
      asset = release.assets.${system};
      helium = pkgsLatest.appimageTools.wrapType2 {
        pname = "helium";
        inherit (release) version;
        src = pkgsLatest.fetchurl { inherit (asset) url hash; };
        extraInstallCommands = ''
          install -Dm644 ${
            pkgsLatest.makeDesktopItem {
              name = "helium";
              desktopName = "Helium";
              exec = "helium %U";
              categories = [
                "Network"
                "WebBrowser"
              ];
              mimeTypes = [
                "text/html"
                "x-scheme-handler/http"
                "x-scheme-handler/https"
              ];
            }
          }/share/applications/helium.desktop "$out/share/applications/helium.desktop"
        '';
        meta = {
          description = "Helium web browser, official Linux release";
          homepage = "https://helium.computer";
          license = pkgsLatest.lib.licenses.gpl3;
          platforms = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          mainProgram = "helium";
        };
      };
    in
    {
      environment.systemPackages = [ helium ];
    };
}
