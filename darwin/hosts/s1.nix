{pkgs, ...}: {
  users.users."alastai.flynn" = {
    name = "alastai.flynn";
    home = "/Users/alastai.flynn";
    shell = pkgs.fish;
  };

  # The user that the user level system.defaults options apply to.
  system.primaryUser = "alastai.flynn";
}
