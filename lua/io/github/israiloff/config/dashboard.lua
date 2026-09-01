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
---The icon carries the colour and the label stays neutral, the way the
---which-key menus in this configuration read: colour on every word is colour
---that says nothing, and a row of six identical grey lines has to be read
---rather than scanned.
---
---Ranges are byte offsets into the label, which is why the icon's byte length
---rather than its width ends the first one. Alpha adds the centring padding to
---them itself.
---@param shortcut string
---@param icon string
---@param label string
---@param command string
---@param icon_hl string
local function entry(shortcut, icon, label, command, icon_hl)
	local button = dashboard.button(shortcut, icon .. " " .. label, command)

	button.opts.hl = {
		{ icon_hl, 0, #icon },
		{ "AlphaButtons", #icon, -1 },
	}
	button.opts.hl_shortcut = "AlphaShortcut"

	return button
end

-- What there is to do before a project is open.
--
-- Finding a file and grepping for text used to be here and are gone: both
-- search the directory the editor happened to start in, which on a start screen
-- is the one thing nobody has chosen yet. Everything below either opens
-- something, makes something, or is about the editor itself.
--
-- The colours are the ones this configuration already uses for those meanings:
-- gold for the way in, the blue it marks changed things with, the green it
-- marks additions with, the keyword orange of the banner for the editor's own
-- settings, and grey for the one entry that is not starting work.
dashboard.section.buttons.val = {
	entry("p", icons.ui.Project, "Projects", ":Telescope projects<CR>", "Function"),
	entry("r", icons.ui.History, "Recent files", ":Telescope oldfiles<CR>", "Number"),
	entry("e", icons.ui.NewFile, "New file", ":ene <BAR> startinsert<CR>", "String"),
	entry(
		"c",
		icons.ui.Settings,
		"Configuration",
		":edit " .. vim.fn.stdpath("config") .. "/lua/io/github/israiloff/config/properties.lua<CR>",
		"Keyword"
	),
	entry("u", icons.plugin.Update, "Update plugins", ":Lazy update<CR>", "Constant"),
	entry("q", icons.ui.SignOut, "Quit", ":qa<CR>", "Comment"),
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
