{pkgs, ...}: {
  users.users."aflynn" = {
    name = "aflynn";
    home = "/Users/aflynn";
    shell = pkgs.fish;
  };

  # The user that the user level system.defaults options apply to.
  system.primaryUser = "aflynn";
}
