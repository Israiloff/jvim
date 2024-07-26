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
			{
				function()
					return " " .. icons.ui.Vim .. " "
				end,
				padding = { left = 0, right = 0 },
			},
		},
		lualine_b = {
			{
				"b:gitsigns_head",
				icon = "%#SLGitIcon#" .. icons.git.Branch .. "%*%#SLBranchName#",
				color = { gui = "bold" },
			},
		},
		lualine_c = {
			{
				"diff",
				source = function()
					local gitsigns = vim.b.gitsigns_status_dict
					if gitsigns then
						return {
							added = gitsigns.added,
							modified = gitsigns.changed,
							removed = gitsigns.removed,
						}
					end
				end,
				symbols = {
					added = icons.git.LineAdded .. " ",
					modified = icons.git.LineModified .. " ",
					removed = icons.git.LineRemoved .. " ",
				},
				padding = { left = 2, right = 1 },
				cond = nil,
			},
		},
		lualine_x = {
			"filename",
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
