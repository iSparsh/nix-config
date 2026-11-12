{ inputs, ... }:
{
  flake.modules.nixos.desktop =
    {
      config,
      lib,
      pkgs,
      pkgsLatest,
      ...
    }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      user = config.local.primaryUser;
    in
    {
      imports = [
        inputs.dux-shell.nixosModules.default
        inputs.dux-files.nixosModules.default
        inputs.dux-greeter.nixosModules.default
      ];

      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };

      programs.dank-material-shell = {
        enable = true;
        package = inputs.dux-shell.packages.${system}.default;
        quickshell.package = pkgsLatest.quickshell;
        systemd.enable = true;
      };

      programs.dux-files = {
        enable = true;
        package = inputs.dux-files.packages.${system}.default;
        systemd.enable = true;
        portal = {
          enable = true;
          preferred = true;
        };
      };

      programs.dms-greeter = {
        enable = true;
        package = inputs.dux-greeter.packages.${system}.default;
        compositor.name = "hyprland";
        # No configHome/configFiles: the owner's Dux settings and plugins stay local.
      };

      services.geoclue2 = {
        enable = true;
        # The upstream location client identifies itself as "dms".
        appConfig.dms = {
          isAllowed = true;
          isSystem = false;
        };
      };
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = pkgs.stdenv.hostPlatform.isx86_64;
        pulse.enable = true;
        wireplumber.enable = true;
      };
      security.rtkit.enable = true;
      security.polkit.enable = true;
      security.pam.services.dankshell = { };
      hardware.graphics.enable = true;
      networking.networkmanager.enable = true;
      services.dbus.enable = true;
      services.gvfs.enable = true;
      services.udisks2.enable = true;

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };

      environment.systemPackages = [
        inputs.dux-search.packages.${system}.default
        pkgs.wl-clipboard
        pkgs.wtype
        pkgs.brightnessctl
        pkgs.playerctl
      ];

      systemd.user.services.dsearch = {
        description = "Dux Search indexer";
        unitConfig.ConditionUser = lib.mkIf (user != null) user;
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = "${inputs.dux-search.packages.${system}.default}/bin/dsearch serve";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      users.users = lib.optionalAttrs (user != null) {
        ${user}.extraGroups = [
          "networkmanager"
          "video"
          "render"
        ];
      };

      # A usable initial compositor config, independent of the current workstation.
      hjem.users = lib.optionalAttrs (user != null) {
        ${user}.xdg.config.files."hypr/hyprland.conf".text = ''
          monitor = , preferred, auto, 1
          $mod = SUPER
          bind = $mod, Return, exec, foot
          bind = $mod, B, exec, helium
          bind = $mod, E, exec, dfiles
          bind = $mod, Space, exec, dms ipc call spotlight toggle
          bind = $mod, Q, killactive,
          bind = $mod SHIFT, E, exit,
          bind = $mod, F, fullscreen,
          bind = $mod, V, togglefloating,
          bindm = $mod, mouse:272, movewindow
          bindm = $mod, mouse:273, resizewindow
          input {
            kb_layout = us
            touchpad {
              natural_scroll = true
            }
          }
          misc {
            disable_hyprland_logo = true
          }
        '';
      };
    };
}
