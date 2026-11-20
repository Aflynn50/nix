{
  config,
  pkgs,
  inputs,
  ...
}: let
  # Own fork of pi-roost, built from the pi-extensions submodule.
  piRoost = import ./pi-roost.nix {inherit pkgs inputs;};
in {
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
        "${piRoost}"
        "npm:@samfp/pi-memory"
        "npm:@samfp/pi-essentials"
        "npm:pi-lsp-extension"
        "npm:pi-session-search"
        # Pinned: third-party, reviewed at these versions. Review diffs on bump.
        "npm:pi-web-access@0.48.0"
        "npm:@alignfirst/pi-background@0.1.3"
        "npm:@juicesharp/rpiv-todo@2.15.0"
        "npm:@narumitw/pi-btw@0.63.8"
      ];
    };
  };

  home.file = let
    dir = config.programs.pi-coding-agent.configDir;
    # Named agents for roost_spawn / `pi --agent` (pi-subagents markdown format).
    # Linked per file so ~/.pi/agent/agents/ stays writable for local agents.
    agents = builtins.listToAttrs (map (n: {
      name = "${dir}/agents/${n}";
      value.source = ./agents + "/${n}";
    }) (builtins.attrNames (builtins.readDir ./agents)));
  in
    agents
    // {
      # MCP servers (pi-native, read from ~/.pi/agent/mcp.json). Read-only store
      # link, so manage servers here rather than with `pi mcp add`.
      # Same Playwright setup as Claude Code (~/.claude.json).
      "${dir}/mcp.json".text = builtins.toJSON {
        mcpServers.playwright = {
          command = "npx";
          args = [
            "@playwright/mcp@latest"
            "--browser"
            "chrome"
            "--output-dir"
            "${config.home.homeDirectory}/.cache/playwright-mcp"
          ];
        };
      };

      # pi-web-access: keyless Exa search, readable-only fetch, no browser cookies.
      "${dir}/web-search.json".text = builtins.toJSON {
        provider = "exa";
        allowBrowserCookies = false;
        fetchRouting.allowRemoteHostedProviders = false;
        fetch.allowedModes = ["readable"];
      };

      # rpiv-todo config (read-only; needs /reload to change).
      ".config/rpiv-todo/config.json".text = builtins.toJSON {
        collapseKey = "ctrl+shift+t";
        maxWidgetLines = 12;
      };

      # Own extensions from the pi-extensions repo (read-only store links). Only
      # individual extension dirs are linked, so ~/.pi/agent/extensions/ stays
      # writable for pi. pi-cd is a locally patched copy of npm:pi-cd.
      "${dir}/extensions/pi-cd".source = "${inputs.pi-extensions}/pi-cd";
      "${dir}/extensions/clear".source = "${inputs.pi-extensions}/clear";
    };
}
