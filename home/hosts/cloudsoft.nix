{
  pkgs,
  lib,
  ...
}: {
  # Host-specific packages for this laptop.
  home.packages = with pkgs; [
    nodejs # provides npm
    # corepack provides the yarn/pnpm shims. nodejs ships its own (older)
    # bin/corepack, so give this one priority to resolve the buildEnv clash.
    (lib.hiPrio corepack)
  ];
}
