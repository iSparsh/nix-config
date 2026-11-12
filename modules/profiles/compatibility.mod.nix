{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      programs.nix-ld = {
        enable = true;

        # Extend the NixOS defaults (C/C++, TLS, compression, system libraries).
        # Keep this focused on common CLI runtimes; add app-specific needs separately.
        libraries = [
          pkgs.libffi
          pkgs.icu
          pkgs.sqlite
          pkgs.ncurses
          pkgs.readline
          pkgs.glib
        ];
      };
    };
}
