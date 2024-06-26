local line = require("lualine").setup({
	--options = {
	--	theme = "lualine.themes.gruvbox-material",
	--},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "filetype" },
		lualine_y = { "location" },
		lualine_z = { "ctime" },
	},
})

--line.options.theme = "lualine.themes.gruvbox-material"
--line.sections.lualine_z = { "ctime" }
