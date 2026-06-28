vim.keymap.set("i", "<M-l>", function()
	return vim.fn["tabby#inline_completion#service#Accept"]()
end, { silent = true, expr = true, desc = "Accept Tabby suggestion" })

vim.keymap.set("i", "¬", function()
	return vim.fn["tabby#inline_completion#service#Accept"]()
end, { silent = true, expr = true, desc = "Accept Tabby suggestion" })
