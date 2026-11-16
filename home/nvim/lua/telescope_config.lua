local telescope = require('telescope')
telescope.setup {
    pickers = {
        find_files = {
            hidden = true,
            no_ignore = true
        }
    },
    defaults = {
        file_ignore_patterns = {
            "%.git/.*",
            "node_modules/.*"
        }
    }
}
telescope.load_extension('fzf')
