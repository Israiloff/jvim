-- Transparent background, so the terminal's own theme shows through.
--
-- Two mechanisms, in order of preference.
--
-- The colourscheme's own, when it has one: `darcula-java` clears every surface
-- it paints — editor, gutter, popups, floats, panels — when it finds
-- `g:darcula_java_transparent` set before it loads. That has to be the primary
-- path, because only the scheme knows which of its colours are surfaces. This
-- config used to keep a list of nine group names instead, written when the
-- scheme painted almost nothing; the moment it started painting properly the
-- list covered a fraction of what it needed to and transparency broke
-- everywhere at once.
--
-- The list below is what is left for every other colourscheme, and it is a
-- best effort by definition: it names the surfaces most schemes have, and a
-- scheme that paints something else keeps its background there.
--
-- The state is read from `properties.gui.transparent` on every check rather than
-- captured once, so the toggle in `config/toggles.lua` takes effect immediately.
local M = {}

local properties = require("io.github.israiloff.config.properties")

local hl_groups_list = {
	"Normal",
	"NormalNC",
	"NormalFloat",
	"FloatBorder",
	"FloatTitle",
	"FloatFooter",
	"SignColumn",
	"LineNr",
	"EndOfBuffer",
	"MsgArea",
	"StatusLine",
	"StatusLineNC",
	"WinBar",
	"WinBarNC",
	"TabLine",
	"TabLineFill",
	"Pmenu",
	"TelescopeNormal",
	"TelescopeBorder",
	"NvimTreeNormal",
	"NvimTreeNormalNC",
	"WhichKeyNormal",
	"WhichKeyBorder",
}

local function enabled()
	return (properties.gui or {}).transparent == true
end

---Tell the colourscheme what to do before it decides.
---
---Read by `darcula-java` while it loads, so it has to be set before the
---`colorscheme` command runs and again before every reload.
local function announce()
	vim.g.darcula_java_transparent = enabled() or nil
end

local function apply_transparency()
	for _, group in ipairs(hl_groups_list) do
		vim.cmd("highlight " .. group .. " guibg=NONE ctermbg=NONE")
	end
end

function M.setup()
	announce()

	-- Loading a colorscheme resets every highlight group, so transparency has to be
	-- re-applied afterwards. Without this, `<leader>sc` / `<leader>sp` (the colorscheme
	-- pickers) silently drop the transparent background.
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("JvimTransparent", { clear = true }),
		callback = function()
			if enabled() then
				apply_transparency()
			end
		end,
	})
end

---Re-apply the current setting. Call after flipping `properties.gui.transparent`.
function M.refresh()
	announce()

	-- Reloading is what applies the change in both directions: the scheme paints
	-- its surfaces or leaves them out according to the flag just set, and the
	-- `ColorScheme` handler above runs the fallback afterwards. Nothing recorded
	-- what the backgrounds held before they were cleared, so switching off has no
	-- other way back.
	local scheme = vim.g.colors_name
	if scheme then
		pcall(vim.cmd.colorscheme, scheme)
	end
end

return M
