{
  flake.modules.nixos.shell =
    {
      config,
      lib,
      pkgs,
      pkgsLatest,
      ...
    }:
    let
      user = config.local.primaryUser;
    in
    {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        histSize = 50000;
        setOptions = [
          "SHARE_HISTORY"
          "HIST_IGNORE_DUPS"
          "HIST_IGNORE_SPACE"
        ];
        shellAliases = {
          ls = "ls --color=auto";
          grep = "rg";
          egrep = "rg";
          fgrep = "rg -F";
          rgi = "rg -i";
          rgh = "rg --hidden --glob '!.git'";
          wiscvpn = "sudo openconnect --protocol=gp uwmadison.vpn.wisc.edu";
        };
        interactiveShellInit = ''
          zstyle ':completion:*' menu select
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
          zstyle ':completion:*' group-name ""
          zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
          zstyle ':completion:*' squeeze-slashes true
          zstyle ':completion:*' use-cache on
          zstyle ':completion:*' cache-path "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

          bindkey -e
          bindkey '^[[H' beginning-of-line '^[[F' end-of-line '^[[3~' delete-char
          bindkey '^[[1;5C' forward-word '^[[1;5D' backward-word

          typeset -U path
          path=("$HOME/.local/bin" "$HOME/.bun/bin" "$HOME/.local/share/pnpm" $path)
          source ${pkgs.fzf}/share/fzf/key-bindings.zsh
          eval "$(${lib.getExe pkgsLatest.zoxide} init zsh --cmd cd)"

          _prompt_command_ran=0
          _prompt_last_command=""
          _prompt_preexec() {
            _prompt_command_ran=1
            _prompt_last_command=$1
          }
          _prompt_precmd() {
            if (( _prompt_command_ran )) && [[ $_prompt_last_command != clear* ]]; then
              print
            fi
            _prompt_command_ran=0
          }
          autoload -Uz add-zsh-hook
          add-zsh-hook preexec _prompt_preexec
          add-zsh-hook precmd _prompt_precmd
        '';
        promptInit = ''eval "$(${lib.getExe pkgsLatest.starship} init zsh)"'';
      };

      environment.systemPackages = [
        pkgsLatest.starship
        pkgsLatest.zoxide
        pkgs.fzf
        pkgs.ripgrep
        pkgs.git
        pkgs.openconnect
      ];

      users.users = lib.optionalAttrs (user != null) {
        ${user}.shell = pkgs.zsh;
      };

      hjem.users = lib.optionalAttrs (user != null) {
        ${user}.xdg.config.files."starship.toml".text = "add_newline = false\n";
      };
    };
}
