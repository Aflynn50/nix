{...}: {
  # This will append onto the fish config created in the common home manager
  # nix files.
  programs.fish.interactiveShellInit = ''
    if status is-interactive
        set -gx AWS_PROFILE "S1A6Dev"
    end
  '';
}
