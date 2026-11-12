{
  flake.modules.nixos.base = {
    boot.loader.limine = {
      enable = true;
      maxGenerations = 5;
    };

    boot.loader.systemd-boot.enable = false;
    boot.loader.grub.enable = false;
  };
}
