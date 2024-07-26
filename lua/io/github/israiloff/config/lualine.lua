local icons = require("io.github.israiloff.config.icons")

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
		lualine_x = {
			{
				"diagnostics",
				sources = { "nvim_diagnostic" },
				symbols = {
					error = icons.diagnostics.BoldError .. " ",
					warn = icons.diagnostics.BoldWarning .. " ",
					info = icons.diagnostics.BoldInformation .. " ",
					hint = icons.diagnostics.BoldHint .. " ",
				},
			},
			"encoding",
			"filetype",
		},
		lualine_y = { "location" },
		lualine_z = {
			function()
				return icons.ui.Clock
			end,
			"ctime",
		},
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
