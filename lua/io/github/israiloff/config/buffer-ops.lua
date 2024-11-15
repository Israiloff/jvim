vim.api.nvim_create_user_command("CmCloseAllBuffers", function()
    local current_buf = vim.api.nvim_get_current_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current_buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
            vim.cmd("bdelete " .. buf)
        end
    end
end, {})
