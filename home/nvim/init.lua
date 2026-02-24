local telescope = require('telescope')
telescope.setup {
    pickers = {
        find_files = {
            hidden = true
        }
    }
}
telescope.load_extension('fzf')

-- Settings for nixd nix language server. The language server itself is
-- installed through home manager as a package.
vim.lsp.config('nixd', {
    autostart = true,
    settings = {
      nixd = {
        nixpkgs = {
          -- I believe that this tells nixd about all nix packages, probably
          -- using the version of nixpkgs set on this machine.
          expr = "import <nixpkgs> { }", 
        },
        formatting = {
          -- alejandra is a syntax highlighter, it is installed as a home manager
          -- package.
          command = { "alejandra" },
        },
        options = {
          -- This does some clever stuff to get the nix config for the current project.
          nixos = {
             expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.k-on.options',
          },
          home_manager = {
             expr = '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."ruixi@k-on".options',
          },
        },
      },
    },
  }
)

-- Format nix files on save.
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.nix",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "nix",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- Load AWS Java config
require('java')

-- Lua config - taken from https://neovim.io/doc/user/lsp/
vim.lsp.config['lua_ls'] = {
  -- Command and arguments to start the server.
  cmd = { 'lua-language-server' },
  -- Filetypes to automatically attach to.
  filetypes = { 'lua' },
  -- Sets the "workspace" to the directory where any of these files is found.
  -- Files that share a root directory will reuse the LSP server connection.
  -- Nested lists indicate equal priority, see |vim.lsp.Config|.
  root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
  -- Specific settings to send to the server. The schema is server-defined.
  -- Example: https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      }
    }
  }
}
