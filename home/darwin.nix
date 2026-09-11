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

    # Needed for the unmodified Home/End/PgUp/PgDn bindings below: Rectangle
    # refuses to register a shortcut with no modifier unless this is set.
    allowAnyShortcut = true;

    # Carried over from the pre-existing config: most of the other bindings
    # (thirds, quadrants, ...) come from Rectangle's alternate default set
    # rather than being listed explicitly.
    alternateDefaultShortcuts = true;
    subsequentExecutionMode = 1;

    # NOTE: not managed by nix -- turn these off by hand on a new machine.
    # macOS's Mission Control "Move left a space" / "Move right a space"
    # (Ctrl+Left / Ctrl+Right) shadow word-skip in text fields. Disable them
    # under System Settings > Keyboard > Keyboard Shortcuts > Mission Control.
    # They are ids 79 and 81 in the com.apple.symbolichotkeys domain, which is
    # deliberately left alone: targets.darwin.defaults would need every one of
    # the ~21 system hotkeys declared, since `defaults import` replaces the
    # whole domain.

    # Fn + arrows. Fn is not a modifier here: the keyboard rewrites the
    # keycode itself, so Fn+Left arrives as Home, Fn+Right as End, Fn+Up as
    # PgUp and Fn+Down as PgDn, with no Fn bit set in modifierFlags. Rectangle
    # therefore sees bare Home/End/PgUp/PgDn, and the Shift variants carry
    # Shift alone.
    #
    # keyCodes are macOS virtual key codes -- 115 = Home, 119 = End,
    # 116 = PgUp, 121 = PgDn. modifierFlags are raw NSEvent flag sums, so
    # shift = 131072. (The friendly names like "option" only exist inside
    # programs.rectangle's submodule, not here.)
    leftHalf = {
      keyCode = 115; # Fn + Left (Home)
      modifierFlags = 0;
    };
    rightHalf = {
      keyCode = 119; # Fn + Right (End)
      modifierFlags = 0;
    };
    topHalf = {
      keyCode = 116; # Fn + Up (PgUp)
      modifierFlags = 0;
    };
    bottomHalf = {
      keyCode = 121; # Fn + Down (PgDn)
      modifierFlags = 0;
    };

    maximize = {
      keyCode = 116; # Shift + Fn + Up (PgUp)
      modifierFlags = 131072;
    };
    nextDisplay = {
      keyCode = 115; # Shift + Fn + Left (Home)
      modifierFlags = 131072;
    };
    previousDisplay = {
      keyCode = 119; # Shift + Fn + Right (End)
      modifierFlags = 131072;
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
