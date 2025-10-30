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

local function is_kept(buf, cur)
    if buf == cur then
        return true
    end
    if not vim.api.nvim_buf_is_valid(buf) then
        return true
    end
    if not vim.bo[buf].buflisted then
        return true
    end
    if vim.bo[buf].filetype == "NvimTree" then
        return true
    end
    return false
end

vim.api.nvim_create_user_command("CmCloseOtherBuffers", function(opts)
    local force = opts.bang
    local cur = vim.api.nvim_get_current_buf()

    local targets = {}
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if not is_kept(b, cur) then
            table.insert(targets, b)
        end
    end
    if #targets == 0 then
        return
    end

    if not vim.bo[cur].buflisted or vim.bo[cur].filetype == "NvimTree" then
        vim.cmd("enew")
        cur = vim.api.nvim_get_current_buf()
    end

    local wins = vim.api.nvim_list_wins()
    for _, win in ipairs(wins) do
        local b = vim.api.nvim_win_get_buf(win)
        for _, t in ipairs(targets) do
            if b == t then
                pcall(vim.api.nvim_win_set_buf, win, cur)
                break
            end
        end
    end

    for _, b in ipairs(targets) do
        local bt = vim.bo[b].buftype
        local del = (bt == "" or bt == "acwrite") and "bdelete" or "bwipeout"
        local cmd = del .. (force and "! " or " ") .. b
        pcall(vim.api.nvim_command, cmd)
    end
end, { bang = true })

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
