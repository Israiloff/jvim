require("toggleterm").setup({
	size = 20,
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 2,
	start_in_insert = true,
	insert_mappings = true,
	terminal_mappings = true,
	persist_size = true,
	direction = "float",
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
		border = "curved",
		winblend = 0,
	},
})

local Terminal = require("toggleterm.terminal").Terminal

-- Create the terminal instances once and reuse them
local float_term = Terminal:new({ direction = "float", hidden = true })
local vertical_term = Terminal:new({ direction = "vertical", hidden = true, size = 30 })
local horizontal_term = Terminal:new({ direction = "horizontal", hidden = true })

-- Functions to toggle the terminals
function _G.toggle_float_term()
	float_term:toggle()
end

function _G.toggle_vertical_term()
	vertical_term:toggle()
end

function _G.toggle_horizontal_term()
	horizontal_term:toggle()
end

-- Keymaps to toggle terminals with specific directions (Normal mode)
vim.api.nvim_set_keymap(
	"n",
	"<M-3>",
	":lua toggle_float_term()<CR>",
	{ noremap = true, silent = true, desc = "Toggle floating terminal" }
)
vim.api.nvim_set_keymap(
	"n",
	"<M-2>",
	":lua toggle_vertical_term()<CR>",
	{ noremap = true, silent = true, desc = "Toggle vertical terminal" }
)
vim.api.nvim_set_keymap(
	"n",
	"<M-1>",
	":lua toggle_horizontal_term()<CR>",
	{ noremap = true, silent = true, desc = "Toggle horizontal terminal" }
)

-- Terminal mode keymaps to toggle terminals (Terminal mode)
vim.api.nvim_set_keymap(
	"t",
	"<M-3>",
	[[<C-\><C-n>:lua toggle_float_term()<CR>]],
	{ noremap = true, silent = true, desc = "Toggle floating terminal" }
)
vim.api.nvim_set_keymap(
	"t",
	"<M-2>",
	[[<C-\><C-n>:lua toggle_vertical_term()<CR>]],
	{ noremap = true, silent = true, desc = "Toggle vertical terminal" }
)
vim.api.nvim_set_keymap(
	"t",
	"<M-1>",
	[[<C-\><C-n>:lua toggle_horizontal_term()<CR>]],
	{ noremap = true, silent = true, desc = "Toggle horizontal terminal" }
)
