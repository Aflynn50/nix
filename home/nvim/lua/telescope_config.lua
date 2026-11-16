local telescope = require('telescope')
telescope.setup {
    pickers = {
        find_files = {
            hidden = true,
            no_ignore = true
        },
        live_grep = {
            additional_args = { "--hidden", "--no-ignore" }
        }
    },
    defaults = {
        file_ignore_patterns = {
            "%.git/.*",
            "%.claude/.*",
            "node_modules/.*"
        }
    }
}
telescope.load_extension('fzf')
