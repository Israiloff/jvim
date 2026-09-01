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

-- Set footer
dashboard.section.footer.val = {
	"Java NeoVim IDE v" .. properties.version,
}

return dashboard
