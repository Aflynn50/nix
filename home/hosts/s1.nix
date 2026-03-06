{...}: {
  # This will append onto the fish config created in the common home manager
  # nix files.
  programs.fish.interactiveShellInit = ''
    if status is-interactive
        set -Ux AWS_PROFILE "AdministratorAccessV2-927675079783"
    end
  '';
}
