vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true

vim.api.nvim_set_keymap("i", "<M-l>", 'copilot#Accept("<CR>")', {
    silent = true,
    expr = true,
})

-- Keymap for MAC OS (Option + l)
vim.api.nvim_set_keymap("i", "¬", 'copilot#Accept("<CR>")', {
    silent = true,
    expr = true,
})
