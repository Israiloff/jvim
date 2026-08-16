-- Transparent background, so the terminal's own theme shows through.
--
-- The state is read from `properties.gui.transparent` on every check rather than
-- captured once, so the toggle in `config/toggles.lua` takes effect immediately.
local M = {}

local properties = require("io.github.israiloff.config.properties")

local hl_groups_list = {
	"Normal",
	"SignColumn",
	"NormalNC",
	"TelescopeBorder",
	"NvimTreeNormal",
	"NvimTreeNormalNC",
	"EndOfBuffer",
	"MsgArea",
	"WinBarNC",
}

local function enabled()
	return (properties.gui or {}).transparent == true
end

local function apply_transparency()
	for _, group in ipairs(hl_groups_list) do
		vim.cmd("highlight " .. group .. " guibg=NONE ctermbg=NONE")
	end
end

function M.setup()
	if enabled() then
		apply_transparency()
	end

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
	if enabled() then
		apply_transparency()
		return
	end

	-- Nothing recorded what the backgrounds held before they were cleared, so
	-- switching off means repainting them from the colorscheme. Reloading fires
	-- ColorScheme again; the handler above sees the new state and leaves the
	-- backgrounds alone.
	local scheme = vim.g.colors_name
	if scheme then
		pcall(vim.cmd.colorscheme, scheme)
	end
end

return M
