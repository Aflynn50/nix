{
  config,
  pkgs,
  ...
}: {
  # pi coding agent. Uses the upstream home-manager module in mutable mode:
  # on each switch these settings are jq-merged into ~/.pi/agent/settings.json,
  # which stays writable so pi can still `pi install`, `pi update`, change model, etc.
  #   - Declared values win on activation; everything else pi wrote is kept.
  #   - Packages are matched by name (version/ref ignored); undeclared ones pi
  #     installed are kept. Removing one here does NOT remove it from the file
  #     (use `pi remove <source>` as well).
  #   - Don't pin versions here unless you want switch to undo `pi update`.
  #   - Quit pi before switching to avoid concurrent writes.
  # Host-specific packages/providers are added from home/hosts/*.nix (lists concatenate).
  programs.pi-coding-agent = {
    enable = true;
    package = pkgs.pi-coding-agent;
    # npm is needed for pi to install npm: packages.
    extraPackages = [pkgs.nodejs];
    mutableSettings = true;
    settings = {
      theme = "light";
      packages = [
        "npm:pi-roost"
        "npm:@samfp/pi-memory"
        "npm:@samfp/pi-essentials"
        "npm:pi-lsp-extension"
        "npm:pi-knowledge-search"
        "npm:pi-session-search"
      ];
    };
  };

  # Vendored, reviewed extensions (read-only store links). Only individual
  # extension dirs are linked, so ~/.pi/agent/extensions/ stays writable for pi.
  # pi-cd is a locally patched copy of npm:pi-cd (see header in index.ts).
  home.file."${config.programs.pi-coding-agent.configDir}/extensions/pi-cd".source = ./extensions/pi-cd;
}
