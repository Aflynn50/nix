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

-- Keymap --

-- Window navigation
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")

-- Ctrl-backspace to delete previous word
vim.keymap.set("!", "<C-BS>", "<C-w>")
vim.keymap.set("!", "<C-h>", "<C-w>")

vim.keymap.set("n", "<leader>t", function()
    require("nvim-tree.api").tree.toggle({
        path = "<args>",
        find_file = false,
        update_root = false,
        focus = true,
    })
end)

-- Leap.nvim
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>f', '<Plug>(leap)')
vim.keymap.set('n', '<leader>F', '<Plug>(leap-from-window)')

-- Telescope keymaps --
-- My mappings
vim.keymap.set("n", "<C-p>", function() require("telescope.builtin").find_files() end)
vim.keymap.set("n", "<leader>g", function() require("telescope.builtin").live_grep() end)

-- Suggested default mappings
vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files() end)
vim.keymap.set("n", "<leader>fg", function() require("telescope.builtin").live_grep() end)
vim.keymap.set("n", "<leader>fb", function() require("telescope.builtin").buffers() end)
vim.keymap.set("n", "<leader>fh", function() require("telescope.builtin").help_tags() end)

-- LSPConfig
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<C-n>', vim.diagnostic.goto_next)
vim.keymap.set('n', '<C-m>', vim.diagnostic.goto_prev)

-- Diagnostic display: a short message at the end of the line (virtual_text)
-- plus the full message rendered beneath the code (virtual_lines).
vim.diagnostic.config({
    virtual_text = true,
    virtual_lines = false,
    signs = true,
    underline = true,
})

-- Show the diagnostic float automatically once the cursor rests, using the
-- updatetime set at the top of this file. focus = false stops the float from
-- stealing the cursor when it reopens.
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, {
            focus = false,
            scope = "cursor",
            close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre", "WinLeave" },
        })
    end,
})

-- Smart Ctrl-]: jump to the definition, unless the cursor is already on the
-- definition, in which case show the usages in telescope (matches IntelliJ's
-- Ctrl+B behaviour).
local function goto_definition_or_usages()
    -- Ask the server where the definition is. Params are built per-client so
    -- the correct position encoding (utf-8/16/32) is used.
    vim.lsp.buf_request(0, 'textDocument/definition', function(client, _)
        return vim.lsp.util.make_position_params(0, client.offset_encoding)
    end, function(_, result)
        if result == nil or vim.tbl_isempty(result) then
            vim.notify('No definition found', vim.log.levels.INFO)
            return
        end
        -- Result is a Location, Location[] or LocationLink[].
        local target = vim.islist(result) and result[1] or result
        local uri = target.uri or target.targetUri
        local range = target.range or target.targetSelectionRange
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1 -- LSP lines are 0-based
        local at_definition = uri == vim.uri_from_bufnr(0)
            and row >= range.start.line
            and row <= range['end'].line
        if at_definition then
            require('telescope.builtin').lsp_references({ include_declaration = false })
        else
            vim.lsp.buf.definition()
        end
    end)
end
vim.keymap.set('n', '<C-]>', goto_definition_or_usages, { desc = 'Goto definition / show usages' })

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

-- nvim-tree
-- disable netrw (built in file tree) at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

local nvim_tree_config = {
    renderer = {
        group_empty = true,
    },
    update_focused_file = {
        enable = true,
        update_root = {
            enable = true,
        },
    }
}
require("nvim-tree").setup(nvim_tree_config)

vim.keymap.set("n", "<leader>t", function()
    require("nvim-tree.api").tree.toggle()
end)

-- Python pyright lsp
vim.lsp.enable('pyright')

-- Typescript lsp
require("typescript-tools").setup {}
vim.lsp.enable("typescript-tools")


-- Load plugin config
require('telescope_config')
require('treesitter_config')
require('java')
