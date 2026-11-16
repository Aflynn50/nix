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

  upstreamSkills = lib.listToAttrs (map (path: {
      name = baseNameOf path;
      value = "${inputs.mattpocock-skills}/${path}";
    })
    mattpocockPaths);

  # Local skills: every directory in ./skills. A local skill shadows an
  # upstream skill of the same name, so to customize one, copy it into
  # ./skills/<name> (and `git add` it; flakes only see tracked files).
  localSkills =
    lib.mapAttrs (name: _: ./skills + "/${name}")
    (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./skills));

  # name -> source path (local wins)
  skills = upstreamSkills // localSkills;

  # Claude Code reads ~/.claude/skills; point each entry at ~/.agents/skills.
  claudeLink = name:
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.agents/skills/${name}";
in {
  home.file =
    lib.mapAttrs' (name: src: lib.nameValuePair ".agents/skills/${name}" {source = src;}) skills
    // lib.mapAttrs' (name: _: lib.nameValuePair ".claude/skills/${name}" {source = claudeLink name;}) skills;
}
