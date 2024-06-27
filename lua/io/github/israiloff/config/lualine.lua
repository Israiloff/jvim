---@diagnostic disable: param-type-mismatch
local nvim_tree_shift = {
	function()
		len = vim.api.nvim_win_get_width(require("nvim-tree.view").get_winnr()) - 1
		title = "Nvim-Tree"
		left = (len - #title) / 2
		right = len - left - #title
		return string.rep(" ", left) .. title .. string.rep(" ", right)
	end,
	cond = require("nvim-tree.view").is_visible,
	color = "Normal",
}

require("lualine").setup({
	options = {
		icons_enabled = true,
		component_separators = {
			left = "",
			right = "",
		},
		section_separators = {
			left = "",
			right = "",
		},
		disabled_filetypes = {
			--"NvimTree",
			"TelescopePrompt",
			"packer",
			"toggleterm",
		},
		always_divide_middle = true,
		globalstatus = true,
	},
	sections = {
		lualine_a = {
			nvim_tree_shift,
			"mode",
		},
		lualine_b = { "branch" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
})
