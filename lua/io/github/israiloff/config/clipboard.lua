vim.g.clipboard = {
    name = "cb",
    copy = {
        ["+"] = "cb copy",
        ["*"] = "cb copy",
    },
    paste = {
        ["+"] = "cb paste",
        ["*"] = "cb paste",
    },
    cache_enabled = 0,
}

vim.opt.clipboard:append("unnamedplus")
