# Claude Code configuration with caveman plugin
{ config, pkgs, lib, ... }:

let
  caveman = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    rev = "600e8efcd6aca4006051ca2a889aa8100a9b3967";
    hash = "sha256-gDPgQx1TIhGrJ2EVvEoDY+4MXdlI79zdcx6pL5nMEG4=";
  };

  hooksDir = "${config.home.homeDirectory}/.claude/hooks";

  cavemanSettings = {
    skipDangerousModePermissionPrompt = true;
    hooks = {
      SessionStart = [{
        hooks = [{
          type = "command";
          command = "node ${hooksDir}/caveman-activate.js";
          timeout = 5;
        }];
      }];
      UserPromptSubmit = [{
        hooks = [{
          type = "command";
          command = "node ${hooksDir}/caveman-mode-tracker.js";
          timeout = 5;
        }];
      }];
    };
    statusLine = {
      type = "command";
      command = "bash ${hooksDir}/caveman-statusline.sh";
    };
  };
in
{
  home.packages = [ pkgs.unstable.claude-code ];

  # Install caveman hook scripts as symlinks into ~/.claude/hooks/
  # Node resolves __dirname via symlink, so relative requires and SKILL.md path work correctly
  home.file.".claude/hooks/caveman-activate.js".source = "${caveman}/hooks/caveman-activate.js";
  home.file.".claude/hooks/caveman-mode-tracker.js".source = "${caveman}/hooks/caveman-mode-tracker.js";
  home.file.".claude/hooks/caveman-config.js".source = "${caveman}/hooks/caveman-config.js";
  home.file.".claude/hooks/caveman-statusline.sh".source = "${caveman}/hooks/caveman-statusline.sh";

  # Skills directory — caveman-activate.js reads SKILL.md via relative path
  # from __dirname (hooks/) up to ../skills/caveman/SKILL.md
  home.file.".claude/skills/caveman/SKILL.md".source = "${caveman}/skills/caveman/SKILL.md";

  # Merge caveman hooks into ~/.claude/settings.json on each activation.
  # Using activation (not home.file) keeps the file writable so Claude Code
  # can still persist permission grants and other runtime settings.
  home.activation.claudeCavemanSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    let
      settingsJson = lib.escapeShellArg (builtins.toJSON cavemanSettings);
    in ''
      settings_dir="$HOME/.claude"
      settings_file="$settings_dir/settings.json"
      mkdir -p "$settings_dir"
      if [ -f "$settings_file" ]; then
        tmp=$(${pkgs.coreutils}/bin/mktemp)
        ${pkgs.jq}/bin/jq ". * ${settingsJson}" "$settings_file" > "$tmp" \
          && mv "$tmp" "$settings_file"
      else
        echo ${settingsJson} > "$settings_file"
      fi
    ''
  );
}
