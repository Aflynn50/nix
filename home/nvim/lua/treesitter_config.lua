-- Treesitter moved from the master branch to the main branch which had a lot of breaking changes. Make sure any docs you are reading are for the main branch.
-- It appears the treesitter public repo is also now archived, not sure what to do about that.
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        -- pcall: filetypes without an installed parser no-op instead of erroring.
        pcall(vim.treesitter.start, args.buf)
    end,
})
