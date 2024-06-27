require("lualine").setup({
	sections = {
		lualine_a = {
			"mode",
			color = nil,
		},
		lualine_b = {
			"branch",
			"diff",
			"diagnostics",
			color = nil,
		},
		lualine_c = {
			"filename",
			color = nil,
		},
		lualine_x = {
			"filetype",
			color = nil,
		},
		lualine_y = {
			"location",
			color = nil,
		},
		lualine_z = {
			"ctime",
			color = nil,
		},
	},
})
