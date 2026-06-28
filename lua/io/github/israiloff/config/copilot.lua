vim.keymap.set("i", "<M-l>", function()
	return vim.fn["copilot#Accept"]("<CR>")
end, {
	silent = true,
	expr = true,
	desc = "Accept Copilot suggestion",
})

vim.keymap.set("i", "¬", function()
	return vim.fn["copilot#Accept"]("<CR>")
end, {
	silent = true,
	expr = true,
	desc = "Accept Copilot suggestion",
})
