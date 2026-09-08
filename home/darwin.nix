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
  programs.rectangle.enable = true; # installs the app; prefs are set below

  # Rectangle's preferences CANNOT be managed with programs.rectangle's
  # defaults/shortcuts options: those write via home.file, which symlinks into
  # the nix store, and macOS's preferences daemon refuses to read a symlinked
  # plist in ~/Library/Preferences -- `defaults read com.knollsoft.Rectangle`
  # reports "domain does not exist" even after restarting cfprefsd.
  #
  # targets.darwin.defaults instead runs `defaults import`, which goes through
  # cfprefsd properly. Note that `defaults import` REPLACES the entire domain
  # on every activation, so every setting we care about has to be listed here;
  # anything omitted reverts to Rectangle's built-in default.
  targets.darwin.defaults."com.knollsoft.Rectangle" = {
    launchOnLogin = true;

    # Option+arrow collides with macOS's word-wise text navigation, which
    # Rectangle would otherwise refuse to bind over.
    allowAnyShortcut = true;

    # Carried over from the pre-existing config: most of the other bindings
    # (thirds, quadrants, ...) come from Rectangle's alternate default set
    # rather than being listed explicitly.
    alternateDefaultShortcuts = true;
    subsequentExecutionMode = 1;

    # Option + arrows, replacing the old Fn + arrows. Fn is consumed by the
    # keyboard itself, which is why the old export showed bare
    # Home/End/PgUp/PgDn with modifierFlags = 0.
    #
    # keyCodes are macOS virtual key codes; modifierFlags are raw NSEvent flag
    # sums -- option = 524288, shift+option = 131072 + 524288 = 655360. (The
    # friendly names like "option" only exist inside programs.rectangle's
    # submodule, not here.)
    leftHalf = {
      keyCode = 123; # Option + Left
      modifierFlags = 524288;
    };
    rightHalf = {
      keyCode = 124; # Option + Right
      modifierFlags = 524288;
    };
    topHalf = {
      keyCode = 126; # Option + Up
      modifierFlags = 524288;
    };
    bottomHalf = {
      keyCode = 125; # Option + Down
      modifierFlags = 524288;
    };

    maximize = {
      keyCode = 126; # Shift + Option + Up
      modifierFlags = 655360;
    };
    nextDisplay = {
      keyCode = 123; # Shift + Option + Left
      modifierFlags = 655360;
    };
    previousDisplay = {
      keyCode = 124; # Shift + Option + Right
      modifierFlags = 655360;
    };
  };

  # Below home.stateVersion 25.11, Home Manager *symlinks* app bundles into
  # ~/Applications/Home Manager Apps, and macOS will not index a symlinked
  # .app -- so Rectangle never appears in Spotlight or Launchpad. copyApps
  # rsyncs real bundles there instead. The two options assert against each
  # other, so linkApps has to be disabled explicitly.
  targets.darwin.linkApps.enable = false;
  targets.darwin.copyApps.enable = true;
}
