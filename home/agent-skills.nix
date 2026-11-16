{
  config,
  inputs,
  lib,
  ...
}: let
  # Skills are linked individually (not the whole dir) so ~/.agents/skills and
  # ~/.claude/skills stay writable, e.g. for local skills, Claude's own
  # `synced` dir, or `npx skills add` experiments.
  # Update: `nix flake update mattpocock-skills`, then switch.

  # Upstream's own plugin manifest lists the canonical skill set, so new/removed
  # skills follow `nix flake update` automatically.
  mattpocockPaths =
    map (lib.removePrefix "./")
    (lib.importJSON "${inputs.mattpocock-skills}/.claude-plugin/plugin.json").skills;

  # name -> source path
  skills =
    lib.listToAttrs (map (path: {
        name = baseNameOf path;
        value = "${inputs.mattpocock-skills}/${path}";
      })
      mattpocockPaths)
    // {
      # Local skills live in ./skills
      create-pr = ./skills/create-pr;
    };

  # Claude Code reads ~/.claude/skills; point each entry at ~/.agents/skills.
  claudeLink = name:
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.agents/skills/${name}";
in {
  home.file =
    lib.mapAttrs' (name: src: lib.nameValuePair ".agents/skills/${name}" {source = src;}) skills
    // lib.mapAttrs' (name: _: lib.nameValuePair ".claude/skills/${name}" {source = claudeLink name;}) skills;
}
