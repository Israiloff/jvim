-- Custom highlight groups referenced by the lualine components (`%#SLxxx#`).
--
-- These are re-applied on ColorScheme because loading a colorscheme clears all
-- highlight groups, which used to leave the statusline unstyled after switching
-- themes via `<leader>sc` / `<leader>sp`.
local highlights = {
	SLNvimIcon = { fg = "#39FF14", bold = true },
	SLGitIcon = { fg = "#F1502F", bold = true },
	SLGitBranchName = { fg = "#E5C07B", bold = true },
	SLCopilotIcon = { fg = "#199FD7", bold = true },
	SLTabbyIcon = { fg = "#73C4FF", bold = true },
	SLClock = { fg = "#E5C07B", bold = true },
	SLIcon_jdtls = { fg = "#C792EA", bold = true },
	SLIcon_lua_ls = { fg = "#51A0CF", bold = true },
	SLIcon_jsonls = { fg = "#F1C40F", bold = true },
	SLIcon_marksman = { fg = "#9AA5CE", bold = true },
	SLIcon_yamlls = { fg = "#C678DD", bold = true },
	SLIcon_stylua = { fg = "#56B6C2", bold = true },
	SLIcon_prettier = { fg = "#FF75A0", bold = true },
	SLIcon_lemminx = { fg = "#E37933", bold = true },
	SLIcon_dockerls = { fg = "#2496ED", bold = true },
	SLIcon_shfmt = { fg = "#98C379", bold = true },
}

local function apply_highlights()
	for group, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, opts)
	end
end

apply_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("JvimStatuslineColors", { clear = true }),
	callback = apply_highlights,
})
