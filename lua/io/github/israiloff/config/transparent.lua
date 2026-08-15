local prop_status, properties = pcall(require, "io.github.israiloff.config.properties")

if not prop_status or not properties.gui.transparent then
	return
end

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

local function apply_transparency()
	for _, group in ipairs(hl_groups_list) do
		vim.cmd("highlight " .. group .. " guibg=NONE ctermbg=NONE")
	end
end

apply_transparency()

-- Loading a colorscheme resets every highlight group, so transparency has to be
-- re-applied afterwards. Without this, `<leader>sc` / `<leader>sp` (the colorscheme
-- pickers) silently drop the transparent background.
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("JvimTransparent", { clear = true }),
	callback = apply_transparency,
})
