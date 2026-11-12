{ inputs, ... }:
let
  makePlaywright =
    packages:
    packages.writeShellApplication {
      name = "playwright";
      runtimeInputs = [ packages.nodejs ];
      text = ''
        export PLAYWRIGHT_BROWSERS_PATH=${packages.playwright-driver.browsers}
        export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
        exec node ${packages.playwright-driver}/package/cli.js "$@"
      '';
    };
in
{
  flake.modules.nixos.development =
    {
      config,
      lib,
      pkgs,
      pkgsLatest,
      ...
    }:
    let
      user = config.local.primaryUser;
      playwright = makePlaywright pkgsLatest;
    in
    {
      environment.systemPackages = with pkgsLatest; [
        nodejs
        bun
        pnpm
        rustc
        cargo
        rustfmt
        clippy
        rust-analyzer
        uv
        python3
        gcc
        gnumake
        cmake
        ninja
        pkg-config
        openssl.dev
        git
        curl
        wget
        jq
        unzip
        zip
        docker-compose
        docker-buildx
        lazydocker
        playwright
      ];

      programs.npm = {
        enable = true;
        npmrc = "prefix=\${HOME}/.local";
      };

      environment.sessionVariables = {
        BUN_INSTALL = "$HOME/.bun";
        PNPM_HOME = "$HOME/.local/share/pnpm";
      };

      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
      };

      users.users = lib.optionalAttrs (user != null) {
        ${user}.extraGroups = [ "docker" ];
      };

      # Project Playwright versions can need different browser revisions. Use
      # this dev shell with its matching driver instead of setting a global path.
      environment.etc."nix-config/playwright-version".text = pkgsLatest.playwright-driver.version;
    };

  perSystem =
    { system, ... }:
    let
      latest = inputs.nixpkgs-unstable.legacyPackages.${system};
    in
    {
      devShells.playwright = latest.mkShell {
        packages = [
          latest.nodejs
          (makePlaywright latest)
        ];
        PLAYWRIGHT_BROWSERS_PATH = latest.playwright-driver.browsers;
        PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
      };
    };

}
