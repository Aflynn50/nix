{pkgs, ...}: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [pkgs.vim];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable shell integration. This needs to be done here as well as in
  # home manager. Enabling it here populates the path with nix locations.
  programs.fish.enable = true;
  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Let Determinate Nix handle Nix configuration
  nix.enable = false;

  # Enable touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Set the nix managed shells as potenetial system shells in /etc/shells
  # The actual login shell still needs to be configured manually with:
  #   chsh -s /run/current-system/sw/bin/zsh
  environment.shells = [ pkgs.fish pkgs.zsh ];
}
