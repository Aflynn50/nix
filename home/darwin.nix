# macOS-only home-manager configuration.
#
# Imported from flake.nix's mkDarwinSystem, which is only ever called for the
# darwinConfigurations, so this file is never evaluated on the Linux hosts and
# nothing in here needs a platform guard.
{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.rectangle = {
    enable = true;
  };
}
