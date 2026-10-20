{
  pkgs,
  lib,
  ...
}: {
  # Host-specific packages for this laptop.
  home.packages = with pkgs; [
    nodejs # provides npm
    playwright
    playwright-test
    # corepack provides the yarn/pnpm shims. nodejs ships its own (older)
    # bin/corepack, so give this one priority to resolve the buildEnv clash.
    (lib.hiPrio corepack)
  ];

  # Use the work email for git on this laptop, overriding the common one.
  programs.git.settings.user.email = lib.mkForce "alastairflynn@cloudsoftcorp.com";
}
