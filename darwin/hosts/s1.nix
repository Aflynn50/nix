{pkgs, ...}: {
  users.users."alastai.flynn" = {
    name = "alastai.flynn";
    home = "/Users/alastai.flynn";
    shell = pkgs.fish;
  };
}
