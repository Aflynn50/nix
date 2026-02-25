{
  config,
  pkgs,
  lib,
  ...
}: {
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # utils
    coreutils # gnu coreutils
    ripgrep
    jq
    yq
    tree
    sl
    gnused # sed

    # lsp/file formatters
    alejandra # .nix file formatter
    nixd # nix lsp
    lua-language-server  
  ];

  # nvim config
  programs.neovim = import ./nvim/nvim.nix {inherit pkgs;};
  home.file.".config/nvim/lua" = {
    source = ./nvim/lua;
    recursive = true;
  };

  # starship
  programs.starship = {
    enable = true;
  };
  home.file.".config/starship.toml" = {
    source = ./dotfiles/.config/starship.toml;
  };

  # fish shell.
  programs.fish = {
    enable = true;

    # More config.fish is added in the hosts modules for specific hosts.
    interactiveShellInit = builtins.readFile ./dotfiles/.config/fish/config.fish;

    plugins = [
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
      {
        name = "bass";
        src = pkgs.fishPlugins.bass.src;
      }
    ];
  };

  # Copy your other directories
  home.file.".config/fish/functions" = {
    source = ./dotfiles/.config/fish/functions;
    recursive = true;
  };
  home.file.".config/fish/completions" = {
    source = ./dotfiles/.config/fish/completions;
    recursive = true;
  };
  home.file.".config/fish/conf.d" = {
    source = ./dotfiles/.config/fish/conf.d;
    recursive = true;
  };

  # ghostty currently doesn't build from source on MacOS so this just manages the config.
  programs.ghostty = import ./ghostty/ghostty.nix {inherit pkgs;};

  # ZSH config
  home.file.".oh-my-zsh" = {
    source = ./dotfiles/.oh-my-zsh;
    recursive = true;
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "shrink-path"];
      custom = "${config.home.homeDirectory}/.oh-my-zsh/custom";
      theme = "aflynn";
    };
    # More initContent is added in the hosts modules for specific hosts.
    initContent = '''';
  };

  # Enviromental variables
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Git
  programs.git = {
    enable = true;
    settings.user.name = "Aflynn50";
    settings.user.email = "af@aflynn.uk";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
