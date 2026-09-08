{pkgs, ...}: {
  # Host-specific packages for this laptop.
  home.packages = with pkgs; [
    nodejs # provides npm
  ];
}
