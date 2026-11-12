{ config, lib, ... }:
let
  directory = ../../themes/victus-graphite;
  palette = builtins.fromJSON (builtins.readFile (directory + /palette.json));
  names = builtins.attrNames palette;
  render =
    file:
    builtins.replaceStrings (map (name: "@${name}@") names) (map (name: palette.${name}) names) (
      builtins.readFile (directory + "/${file}")
    );
  renderFoot = builtins.replaceStrings (map (name: "@${name}@") names) (map (
    name: lib.removePrefix "#" palette.${name}
  ) names) (builtins.readFile (directory + /foot.ini.in));
in
{
  flake.modules.nixos.appearance =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      user = config.local.primaryUser;
      assets =
        pkgs.runCommand "victus-graphite"
          {
            dms = pkgs.writeText "dms.json" (render "dms.json.in");
            zed = pkgs.writeText "zed.json" (render "zed.json.in");
            obsidian = pkgs.writeText "obsidian.css" (render "obsidian.css.in");
            t3 = pkgs.writeText "t3.json" (render "t3.json.in");
          }
          ''
            mkdir -p "$out"
            cp "$dms" "$out/dms.json"
            cp "$zed" "$out/zed.json"
            cp "$obsidian" "$out/obsidian.css"
            cp "$t3" "$out/t3.json"
            cp ${directory + /obsidian-manifest.json} "$out/obsidian-manifest.json"
          '';
      python = pkgs.python3.withPackages (ps: [ ps.json5 ]);
      applyAppearance = pkgs.writeShellApplication {
        name = "apply-shared-appearance";
        text = ''exec ${python}/bin/python ${../../scripts/apply-appearance.py} --assets ${assets} "$@"'';
      };
    in
    {
      environment.systemPackages = [ applyAppearance ];
      environment.etc."nix-config/themes/victus-graphite".source = assets;

      hjem.users = lib.optionalAttrs (user != null) {
        ${user}.files = {
          ".config/dms/themes/victus-graphite/theme.json".source = "${assets}/dms.json";
          ".config/zed/themes/victus-graphite.json".source = "${assets}/zed.json";
          ".t3/userdata/themes/victus-graphite.json".source = "${assets}/t3.json";
          ".config/foot/foot.ini".text = renderFoot;
        };
      };

      systemd.user.services.shared-appearance = lib.mkIf (user != null) {
        description = "Apply managed fonts and themes while preserving other app settings";
        wantedBy = [ "default.target" ];
        unitConfig.ConditionUser = user;
        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.getExe applyAppearance;
        };
      };

      systemd.user.paths.shared-appearance = lib.mkIf (user != null) {
        description = "Apply the Obsidian theme when a vault is registered";
        wantedBy = [ "default.target" ];
        unitConfig.ConditionUser = user;
        pathConfig.PathChanged = "%h/.config/obsidian/obsidian.json";
      };
    };

  # A rendered palette check keeps malformed JSON and unresolved tokens out of CI.
  perSystem = { pkgs, ... }: {
    checks.appearance-settings =
      pkgs.runCommand "appearance-settings"
        {
          nativeBuildInputs = [ (pkgs.python3.withPackages (ps: [ ps.json5 ])) ];
          APPEARANCE_SCRIPT = ../../scripts/apply-appearance.py;
        }
        ''
          python ${../../tests/test_appearance.py}
          touch "$out"
        '';

    checks.theme-adapters =
      pkgs.runCommand "theme-adapters"
        {
          nativeBuildInputs = [ pkgs.python3 ];
          dms = pkgs.writeText "dms.json" (render "dms.json.in");
          zed = pkgs.writeText "zed.json" (render "zed.json.in");
          t3 = pkgs.writeText "t3.json" (render "t3.json.in");
        }
        ''
          python - <<'PY'
          import json, os, re
          for name in ("dms", "zed", "t3"):
              text = open(os.environ[name]).read()
              assert not re.search(r"@[A-Za-z0-9_]+@", text), name
              json.loads(text)
          PY
          touch "$out"
        '';
  };
}
