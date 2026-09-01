local icons = require("io.github.israiloff.config.icons")
local dashboard = require("alpha.themes.dashboard")
local properties = require("io.github.israiloff.config.properties")

dashboard.section.header.val = {
	[[     ██╗██╗   ██╗██╗███╗   ███╗]],
	[[     ██║██║   ██║██║████╗ ████║]],
	[[     ██║██║   ██║██║██╔████╔██║]],
	[[██   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
	[[╚█████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
	[[ ╚════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
}

dashboard.section.header.opts = {
	position = "center",
	-- `AlphaHeader`, not `FloatBorder`. The banner was painted with a border
	-- colour, which cost nothing while the colourscheme left that group alone
	-- and turned the banner grey — on a grey slab — the moment it started
	-- defining it. `AlphaHeader` is the group colourschemes provide for exactly
	-- this, and this one paints it the Darcula keyword orange.
	hl = "AlphaHeader",
}

-- Set the menu
dashboard.section.buttons.val = {
	dashboard.button("f", icons.ui.FindFile .. " Find file", ":Telescope find_files<CR>"),
	dashboard.button("e", icons.ui.NewFile .. " New file", ":ene <BAR> startinsert <CR>"),
	dashboard.button("p", icons.ui.Project .. " Projects", ":Telescope projects<CR>"),
	dashboard.button("r", icons.ui.History .. " Recent files", ":Telescope oldfiles<CR>"),
	dashboard.button("t", icons.ui.FindText .. " Find text", ":Telescope live_grep<CR>"),
	dashboard.button("q", icons.ui.SignOut .. " Quit", ":qa<CR>"),
}

-- What the wordmark stands for, directly under it.
--
-- A logo and its expansion are one thing: `JVIM` only says anything once
-- `Java NeoVim IDE` is next to it. Six lines further down, under the menu, it
-- explained nothing and sat where most configurations put plugin-load counts.
--
-- It is dimmed on purpose. A subtitle in the same orange as the logo competes
-- with it; `AlphaFooter` is the quiet secondary text the colourscheme already
-- provides for this screen.
dashboard.section.subtitle = {
	type = "text",
	val = "Java NeoVim IDE v" .. properties.version,
	opts = {
		position = "center",
		hl = "AlphaFooter",
	},
}

-- The stock layout ends on the footer, which is now empty. Ending on the
-- buttons puts the last thing you look at on the only thing you can act on.
dashboard.config.layout = {
	{ type = "padding", val = 2 },
	dashboard.section.header,
	dashboard.section.subtitle,
	{ type = "padding", val = 2 },
	dashboard.section.buttons,
}

return dashboard
