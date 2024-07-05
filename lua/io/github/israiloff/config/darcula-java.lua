local wk_status, _ = pcall(require, "which-key")

if wk_status then
	vim.api.nvim_set_hl(0, "WhichKeyFloat", { link = "FloatBorder" })
	vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#CD7832" })
end
