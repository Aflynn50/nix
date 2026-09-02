{pkgs, ...}: {
  users.users."aflynn" = {
    name = "aflynn";
    home = "/Users/aflynn";
    shell = pkgs.fish;
  };
}
