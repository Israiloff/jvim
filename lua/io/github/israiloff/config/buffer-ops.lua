vim.api.nvim_create_user_command("CmCloseAllBuffers", function()
    local current_buf = vim.api.nvim_get_current_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current_buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
            vim.cmd("bdelete " .. buf)
        end
    end
end, {})

local function is_normal_listed(b, cur)
    return vim.api.nvim_buf_is_valid(b)
        and vim.api.nvim_buf_is_loaded(b)
        and vim.bo[b].buflisted
        and vim.bo[b].filetype ~= "NvimTree"
        and vim.bo[b].buftype == ""
        and b ~= cur
end

local function is_listed_any(b, cur)
    return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted and vim.bo[b].filetype ~= "NvimTree" and b ~= cur
end

vim.api.nvim_create_user_command("CmCloseCurrentBuffer", function(opts)
    local force = opts.bang
    local cur = vim.api.nvim_get_current_buf()

    local bufs = vim.api.nvim_list_bufs()
    local target = nil

    for _, b in ipairs(bufs) do
        if is_normal_listed(b, cur) then
            target = b
            break
        end
    end

    if not target then
        for _, b in ipairs(bufs) do
            if is_listed_any(b, cur) then
                target = b
                break
            end
        end
    end

    if not target then
        vim.cmd("enew")
        target = vim.api.nvim_get_current_buf()
    else
        vim.cmd("buffer " .. target)
    end

    local bt = vim.bo[cur].buftype
    local del = (bt == "" or bt == "acwrite") and "bdelete" or "bwipeout"
    local cmd = del .. (force and "! " or " ") .. cur
    pcall(vim.api.nvim_command, cmd)
end, { bang = true })
