{pkgs, ...}: {
  users.users.alasflyn = {
    name = "alasflyn";
    home = "/Users/alasflyn";
    shell = pkgs.fish;
  };
}
