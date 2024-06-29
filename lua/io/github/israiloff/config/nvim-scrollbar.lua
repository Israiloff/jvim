require("scrollbar").setup({
	hide_if_all_visible = true,
	show = true,
	throttle_ms = 100,
	handle = {
		text = " ",
		blend = 40,
		color = "#CD7832",
		color_nr = nil,
		highlight = "CursorColumn",
		hide_if_all_visible = true,
	},
})

require("scrollbar.handlers.gitsigns").setup()
