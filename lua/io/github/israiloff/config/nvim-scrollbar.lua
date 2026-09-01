-- The scrollbar handle is deliberately the Darcula keyword orange rather than a
-- neutral grey: it is the one thing on the right edge that has to be findable
-- at a glance, and the theme's own `ScrollbarHandle` is a low-contrast panel
-- colour meant to disappear.
--
-- The value comes from the colourscheme's palette instead of being copied here.
-- It was copied here, and the copy said `#CD7832` against Darcula's `#CC7832` —
-- a hand-transcribed colour drifts, an imported one cannot.
local palette_ok, palette = pcall(require, "darcula-java.palette")

require("scrollbar").setup({
	hide_if_all_visible = true,
	show = true,
	throttle_ms = 100,
	handle = {
		text = " ",
		blend = 40,
		-- `color` wins over `highlight` in nvim-scrollbar, so leaving it unset
		-- is what hands the decision to the group below — which is what should
		-- happen under a colourscheme that has no Darcula palette to ask.
		color = palette_ok and palette.keyword or nil,
		color_nr = nil,
		highlight = "CursorColumn",
		hide_if_all_visible = true,
	},
})

require("scrollbar.handlers.gitsigns").setup()
