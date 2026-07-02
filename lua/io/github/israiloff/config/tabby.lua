local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
	print("Error: 'io.github.israiloff.config.logger' not found")
	return
end

local logger_name = "io.github.israiloff.config.tabby"

local properties_status, properties = pcall(require, "io.github.israiloff.config.properties")

if not properties_status then
	log.error(logger_name, "'io.github.israiloff.config.properties' not found")
	return
end

local tabby_status = pcall(require, "tabby")

if not tabby_status then
	log.error(logger_name, "'tabby' not found")
	return
end

local function color_to_hex(color)
	if type(color) ~= "number" then
		return nil
	end

	return string.format("#%06x", color)
end

local function get_highlight_fg(names, fallback)
	for _, name in ipairs(names) do
		local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
		local fg = ok and color_to_hex(hl.fg)

		if fg then
			return fg
		end
	end

	return fallback
end

local function apply_tabby_highlights()
	if not properties.gui.transparent then
		return
	end

	vim.api.nvim_set_hl(0, "TabbyCompletion", {
		fg = get_highlight_fg({ "TabbyCompletion", "Comment", "NonText" }, "#808080"),
		bg = "NONE",
	})
	vim.api.nvim_set_hl(0, "TabbyCompletionReplaceRange", {
		fg = get_highlight_fg({ "TabbyCompletionReplaceRange", "Comment", "Normal" }, "#303030"),
		bg = "NONE",
	})
end

apply_tabby_highlights()

local highlight_group = vim.api.nvim_create_augroup("JvimTabbyHighlights", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
	group = highlight_group,
	callback = apply_tabby_highlights,
})

vim.api.nvim_create_autocmd("User", {
	group = highlight_group,
	pattern = "tabby_lsp_on_buffer_attached",
	callback = apply_tabby_highlights,
})

local function accept_tabby_suggestion()
	return vim.fn["tabby#inline_completion#service#Accept"]()
end

vim.keymap.set("i", "<M-l>", accept_tabby_suggestion, {
	silent = true,
	expr = true,
	desc = "Accept Tabby suggestion",
})

vim.keymap.set("i", "¬", accept_tabby_suggestion, {
	silent = true,
	expr = true,
	desc = "Accept Tabby suggestion",
})
