{pkgs, ...}: {
  users.users.alasflyn = {
    name = "alasflyn";
    home = "/Users/alasflyn";
    shell = pkgs.fish;
  };

  home-manager.users.alasflyn = {
    # This will append onto the zsh and fish config created in the common home manager nix files.
    programs.zsh.initContent = ''
      export PATH=$HOME/.toolbox/bin:$HOME/.guard/bin:$PATH
      eval "$(/opt/homebrew/bin/brew shellenv)"
      # Set up mise for runtime management
      eval "$(mise activate zsh)"
      source $HOME/.brazil_completion/zsh_completion

      . $HOME/workplace/Uluru/CloudsoftUluruHelpers/src/CloudsoftUluruHelpers/build/bin/install-uluru-scripts.sh --quiet --profile uluru
      export DOCKER_HOST=unix:///Applications/Finch/lima/data/finch/sock/finch.sock
      export DOCKER_CONFIG=/Users/adaridde/ finch
      export CDK_DOCKER=finch
      alias docker=finch

      alias bb=brazil-build
      alias bba='brazil-build apollo-pkg'
      alias bre='brazil-runtime-exec'
      alias brc='brazil-recursive-cmd'
      alias bws='brazil ws'
      alias bwsuse='bws use -p'
      alias bwscreate='bws create -n'
      alias brc=brazil-recursive-cmd
      alias bbr='brc brazil-build'
      alias bball='brc --allPackages'
      alias bbb='brc --allPackages brazil-build'
      alias bbra='bbr apollo-pkg'
    '';
    programs.fish.interactiveShellInit = ''
      fish_add_path ~/.toolbox/bin/
      fish_add_path ~/.guard/bin/
      # bass source $HOME/workplace/Uluru/CloudsoftUluruHelpers/src/CloudsoftUluruHelpers/build/bin/install-uluru-scripts.sh --quiet --profile uluru
    '';
  };
}
