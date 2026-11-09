{
  inputs,
  lib,
  ...
}: let
  # Skills are linked individually (not the whole dir) so ~/.agents/skills stays
  # writable, e.g. for local skills or `npx skills add` experiments.
  # Update: `nix flake update mattpocock-skills`, then switch.
  link = src: path: {
    name = ".agents/skills/${baseNameOf path}";
    value.source = "${src}/${path}";
  };

  # Upstream's own plugin manifest lists the canonical skill set, so new/removed
  # skills follow `nix flake update` automatically.
  mattpocockPaths =
    map (lib.removePrefix "./")
    (lib.importJSON "${inputs.mattpocock-skills}/.claude-plugin/plugin.json").skills;
in {
  home.file = lib.listToAttrs (map (link inputs.mattpocock-skills) mattpocockPaths);
}
