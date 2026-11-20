{
  pkgs,
  inputs,
  ...
}:
# Fork of pi-roost (submodule of the pi-extensions repo), built with tsc so
# dist/ exists. node-pty is native, hence python3 + the Darwin/Linux toolchain.
pkgs.buildNpmPackage {
  pname = "pi-roost";
  version = "fork";
  src = "${inputs.pi-extensions}/pi-roost";
  npmDepsHash = "sha256-l/n0lZv2XZ540c4WE/Tu5QwMYGhnRlMsgSH9zAFy8X0=";
  nativeBuildInputs = [pkgs.python3];
  npmBuildScript = "build";
  # The package is loaded in place by pi, not installed as a CLI.
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';
}
