{
  pkgs,
  inputs,
  ...
}:
# Fork of pi-roost (vendored in the pi-extensions repo), built with tsc so
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
    # node-pty's postinstall normally sets +x on spawn-helper; without it
    # pty.spawn fails with "posix_spawnp failed".
    chmod -R u+w $out/node_modules/node-pty
    find $out/node_modules/node-pty -name spawn-helper -exec chmod +x {} +
    runHook postInstall
  '';
}
