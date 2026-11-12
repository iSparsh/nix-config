{ config, ... }:
{
  fleet.hosts.asus-nixos = {
    system = "x86_64-linux";
    primaryUser = "sparsh";
    profiles = config.fleet.sharedProfiles ++ [ "server" ];

    module =
      { pkgs, ... }:
      {
        imports = [ ./hardware-configuration.nix ];

        boot.loader.efi.canTouchEfiVariables = true;
        boot.kernelPackages = pkgs.linuxPackages_latest;

        time.timeZone = "America/Chicago";

        i18n.defaultLocale = "en_US.UTF-8";
        i18n.extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };

        services.xserver.xkb = {
          layout = "us";
          variant = "";
        };

        services.printing.enable = true;
        services.pulseaudio.enable = false;

        users.users.sparsh = {
          isNormalUser = true;
          description = "Sparsh Mishra";
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
        };

        # Preserve the installation's compatibility baseline and existing password.
        users.mutableUsers = true;
        system.stateVersion = "26.05";
      };
  };
}
