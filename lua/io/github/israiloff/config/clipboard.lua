if vim.fn.executable("win32yank") == 1 then
    -- win32yank is available, use it for clipboard
    vim.g.clipboard = {
        name = "win32yank",
        copy = {
            ["+"] = "win32yank.exe -i --crlf",
            ["*"] = "win32yank.exe -i --crlf",
        },
        paste = {
            ["+"] = "win32yank.exe -o --lf",
            ["*"] = "win32yank.exe -o --lf",
        },
        cache_enabled = 0,
    }
elseif vim.fn.executable("cb") == 1 then
    -- cb is available, use it for clipboard
    vim.g.clipboard = {
        name = "cb_clipboard",
        copy = {
            ["+"] = "cb",
            ["*"] = "cb",
        },
        paste = {
            ["+"] = "cb -o",
            ["*"] = "cb -o",
        },
        cache_enabled = 0,
    }
end

vim.opt.clipboard:append("unnamedplus")
