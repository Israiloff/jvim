vim.api.nvim_create_user_command("CmCloseAllBuffers", function()
    local current_buf = vim.api.nvim_get_current_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current_buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
            vim.cmd("bdelete " .. buf)
        end
    end
end, {})

vim.api.nvim_create_user_command("CmCloseCurrentBuffer", function()
    local current_buf = vim.api.nvim_get_current_buf()
    local buffers = vim.tbl_filter(function(buf)
        return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
    end, vim.api.nvim_list_bufs())

    if #buffers > 1 then
        vim.cmd("bdelete " .. current_buf)
    end
end, {})
