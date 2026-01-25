# Shell configuration module for Home Manager
{ config, pkgs, lib, ... }:

{
  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      share = true;
    };

    shellAliases = {
      ll = "ls -la";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      "..." = "cd ../..";
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline";
    };

    initContent = ''
      # Additional zsh configuration can go here
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = lib.concatStrings [
        "[#](bold blue) "
        "$username"
        " @ "
        "$hostname"
        " in "
        "$directory"
        "$git_branch"
        "$git_status"
        " "
        "\\[$time\\]"
        "$status"
        "$line_break"
        "$character"
      ];

      username = {
        show_always = true;
        format = "[$user](cyan)";
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname](green)";
      };

      directory = {
        format = "[$path](bold yellow)";
        truncation_length = 3;
        truncate_to_repo = false;
      };

      git_branch = {
        format = "[ on](white) [git:](bold white)[$branch](bold purple)";
      };

      git_status = {
        format = "[ $all_status$ahead_behind](bold yellow)";
        conflicted = "=";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        untracked = "?";
        stashed = "$";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      time = {
        disabled = false;
        format = "$time";
        time_format = "%T";
      };

      status = {
        disabled = false;
        format = "[ C:$status](bold red)";
      };

      character = {
        success_symbol = "[\\$](bold red)";
        error_symbol = "[\\$](bold red)";
      };
    };
  };

  # Direnv for per-directory environments
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Fzf fuzzy finder
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
