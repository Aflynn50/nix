vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.cindent = true
vim.opt.smartindent = true
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.scrolloff = 7
vim.opt.mouse = "a"
vim.opt.path:append("*/**")
vim.opt.updatetime = 100
vim.opt.autowrite = true
vim.opt.foldenable = false
vim.opt.termguicolors = true
vim.opt.background = "light"

vim.g.mapleader = " "

vim.cmd("syntax on")
vim.cmd("colorscheme NeoSolarized")

-- Window navigation
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")

-- Ctrl-backspace to delete previous word
vim.keymap.set("!", "<C-BS>", "<C-w>")
vim.keymap.set("!", "<C-h>", "<C-w>")

-- Plugins
vim.g.vim_markdown_folding_disabled = 1
vim.g.airline_theme = "solarized"

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

-- Format nix and lua files on save.
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.nix", "*.lua" },
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
            },
            format = {
                enable = true,
                defaultConfig = {
                    indent_style = "space",
                    indent_size = "2",
                }
            }
        }
    }
}
vim.lsp.enable('lua_ls')

-- Load plugin config
require('telescope')
require('treesitter')
require('java')
