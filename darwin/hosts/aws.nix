{pkgs, ...}: {
  users.users.alasflyn = {
    name = "alasflyn";
    home = "/Users/alasflyn";
    shell = pkgs.zsh;
  };

  # The user that the user level system.defaults options apply to.
  system.primaryUser = "alasflyn";
}
