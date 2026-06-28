vim.g.tabby_agent_start_command = { "npx", "tabby-agent", "--stdio" }

vim.keymap.set("i", "<M-l>", function()
	vim.fn["tabby#Accept"]()
end, { silent = true, desc = "Accept Tabby suggestion" })

vim.keymap.set("i", "¬", function()
	vim.fn["tabby#Accept"]()
end, { silent = true, desc = "Accept Tabby suggestion" })
