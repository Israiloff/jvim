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

---One entry on the start screen.
---
---Icon and label are one colour. Marking the icon separately was tried twice:
---a colour per entry turned six rows into six signals that meant nothing, and
---one accent for all of them put gold at both ends of every row, where it
---blurred into the shortcut it was supposed to be distinct from. The shortcut
---is the only thing on the row worth setting apart, so it is the only thing
---that is.
---
---Both groups come from the colourscheme rather than the `Keyword` alpha
---hardcodes, so the screen follows the theme.
---@param shortcut string
---@param icon string
---@param label string
---@param command string
local function entry(shortcut, icon, label, command)
	local button = dashboard.button(shortcut, icon .. " " .. label, command)

	button.opts.hl = "AlphaButtons"
	button.opts.hl_shortcut = "AlphaShortcut"

	return button
end

-- What there is to do before a project is open.
--
-- Finding a file and grepping for text used to be here and are gone: both
-- search the directory the editor happened to start in, which on a start screen
-- is the one thing nobody has chosen yet. Everything below either opens
-- something, makes something, or is about the editor itself.
dashboard.section.buttons.val = {
	entry("p", icons.ui.Project, "Projects", ":Telescope projects<CR>"),
	entry("r", icons.ui.History, "Recent files", ":Telescope oldfiles<CR>"),
	entry("e", icons.ui.NewFile, "New file", ":ene <BAR> startinsert<CR>"),
	entry(
		"c",
		icons.ui.Settings,
		"Configuration",
		":edit " .. vim.fn.stdpath("config") .. "/lua/io/github/israiloff/config/properties.lua<CR>"
	),
	entry("u", icons.plugin.Update, "Update plugins", ":Lazy update<CR>"),
	entry("q", icons.ui.SignOut, "Quit", ":qa<CR>"),
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
