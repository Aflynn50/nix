{
  config,
  pkgs,
  lib,
  ...
}: let
  # Find all IDE config folders and put the key map in each one.
  jetbrainsBase =
    if pkgs.stdenv.isDarwin
    then "${config.home.homeDirectory}/Library/Application Support/JetBrains"
    else "${config.home.homeDirectory}/.config/JetBrains";

  jetbrainsDirs =
    if builtins.pathExists jetbrainsBase
    then builtins.attrNames (builtins.readDir jetbrainsBase)
    else builtins.trace "Cannot find directory ${jetbrainsBase}: is --impure active?" [];

  prefixes = ["IntelliJIdea" "PyCharm"];

  matchingDirs = builtins.filter (
    name: builtins.any (p: lib.hasPrefix p name) prefixes
  ) jetbrainsDirs;

  keymapEntries = lib.listToAttrs (map (dir: {
    name = jetbrainsBase + "/${dir}/keymaps/Alastair_Nix_Keymap.xml";
    value = {source = ./Alastair_Nix_Keymap.xml;};
  }) matchingDirs);
in {
  home.file = keymapEntries;
}
