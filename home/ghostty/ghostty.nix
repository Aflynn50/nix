{pkgs, lib}: {
  enable = true;
  # Set package to null on darwin so nix doesn't attempt to build it as it
  # doesn't compile on mac. Ghostty will need installed elsewhere.
  package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
  settings = {
    theme = "Violet Light";
    quit-after-last-window-closed = true;
    command = lib.getExe pkgs.fish;
    keybind = [
      "ctrl+left=esc:b"
      "ctrl+right=esc:f"
      "ctrl+alt+left=goto_split:left"
      "ctrl+alt+right=goto_split:right"
      "ctrl+alt+down=goto_split:down"
      "ctrl+alt+up=goto_split:up"
    ];
    shell-integration-features = "ssh-terminfo,ssh-env,sudo";
  };
  enableFishIntegration = true;
}
