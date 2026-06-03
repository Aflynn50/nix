{ pkgs, ... }:
{
  enable = true;
  defaultEditor = true;
  vimAlias = true;
  vimdiffAlias = true;

  plugins = with pkgs.vimPlugins; [
    vim-go
    vim-fugitive
    idris2-vim
    vim-airline
    vim-airline-themes
    vim-markdown
    vim-abolish
    plenary-nvim
    telescope-nvim
    telescope-fzf-native-nvim
    vim-cool
    # (nvim-treesitter.withPlugins (p: [ p.nix p.go p.rust p.lua ]))
    nvim-treesitter.withAllGrammars
    nvim-lspconfig
    rust-vim
    nvim-jdtls
    nvim-tree-lua
    leap-nvim
    plenary-nvim # Dependency of typescript-tools-nvim
    typescript-tools-nvim
    vim-commentary

    # My custom NeoSolarized 
    (pkgs.vimUtils.buildVimPlugin {
      name = "neosolarized-custom";
      src = pkgs.fetchFromGitHub {
        owner = "Aflynn50";
        repo = "NeoSolarized";
        rev = "master";
        sha256 = "rNALVVh8HDNqkE7xQxix/eJjHlysWZeftieM6aAo4r0=";
      };
    })
  ];

  # The defaults for these changed with upgrade to 26.05, I've set them
  # explicitly to remove warnings.
  withRuby = false;
  withPython3 = true;

  # extraConfig = builtins.readFile ./init.vim; -- This has been migrated into the lua dir
  initLua = builtins.readFile ./init.lua;
}
