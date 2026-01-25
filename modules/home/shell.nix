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

    initExtra = ''
      # Additional zsh configuration can go here
    '';
  };

  # Starship prompt (optional, uncomment to enable)
  # programs.starship = {
  #   enable = true;
  #   enableZshIntegration = true;
  # };

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
