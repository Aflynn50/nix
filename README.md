# My Nix Config

Run on darwin with:
```
sudo darwin-rebuild switch --flake .
```
Or for the first time:
```
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .
```

To run just home-manager (linux):
```
home-manager switch --flake . --extra-experimental-features nix-command --extra-experimental-features flakes
```

Update with:
```
nix flake update
```
