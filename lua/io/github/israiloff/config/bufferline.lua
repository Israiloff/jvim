---@diagnostic disable: undefined-field
local icons = require("io.github.israiloff.config.icons")

local function diagnostics_indicator(_, _, diagnostics, _)
	local result = {}

	local symbols = {
		error = icons.diagnostics.Error,
		warning = icons.diagnostics.Warning,
		info = icons.diagnostics.Information,
	}

	for name, count in pairs(diagnostics) do
		if symbols[name] and count > 0 then
			table.insert(result, symbols[name] .. " " .. count)
		end
	end

	---@diagnostic disable-next-line: cast-local-type
	result = table.concat(result, " ")

	return #result > 0 and result or ""
end

local function is_ft(b, ft)
	return vim.bo[b].filetype == ft
end

local function custom_filter(buf, buf_nums)
	local logs = vim.tbl_filter(function(b)
		return is_ft(b, "log")
	end, buf_nums or {})

	if vim.tbl_isempty(logs) then
		return true
	end

	local tab_num = vim.fn.tabpagenr()
	local last_tab = vim.fn.tabpagenr("$")
	local is_log = is_ft(buf, "log")

	if last_tab == 1 then
		return true
	end

	return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
end

require("bufferline").setup({
	options = {
		themable = true,
		get_element_icon = nil,
		show_duplicate_prefix = true,
		duplicates_across_groups = true,
		auto_toggle_bufferline = true,
		move_wraps_at_ends = false,
		groups = { items = {}, options = { toggle_hidden_on_enter = true } },
		mode = "buffers",
		numbers = "none",
		close_command = function(_)
			vim.cmd("bd")
		end,
		right_mouse_command = "vert sbuffer %d",
		left_mouse_command = "buffer %d",
		middle_mouse_command = nil,
		indicator = {
			icon = icons.ui.BoldLineLeft,
			style = "icon",
		},
		buffer_close_icon = icons.ui.Close,
		modified_icon = icons.ui.Circle,
		close_icon = icons.ui.BoldClose,
		left_trunc_marker = icons.ui.ArrowCircleLeft,
		right_trunc_marker = icons.ui.ArrowCircleRight,
		name_formatter = function(buf)
			if buf.name:match("%.md") then
				return vim.fn.fnamemodify(buf.name, ":t:r")
			end
			return buf.name
		end,
		max_name_length = 18,
		max_prefix_length = 15,
		truncate_names = true,
		tab_size = 18,
		diagnostics = "nvim_lsp",
		diagnostics_update_in_insert = false,
		diagnostics_indicator = diagnostics_indicator,
		custom_filter = custom_filter,
		offsets = {
			{
				filetype = "undotree",
				text = "Undotree",
				highlight = "PanelHeading",
				padding = 1,
			},
			{
				filetype = "NvimTree",
				text = "Explorer",
				highlight = "PanelHeading",
				padding = 1,
			},
			{
				filetype = "DiffviewFiles",
				text = "Diff View",
				highlight = "PanelHeading",
				padding = 1,
			},
			{
				filetype = "flutterToolsOutline",
				text = "Flutter Outline",
				highlight = "PanelHeading",
			},
			{
				filetype = "lazy",
				text = "Lazy",
				highlight = "PanelHeading",
				padding = 1,
			},
		},
		color_icons = true,
		show_buffer_icons = true,
		show_buffer_close_icons = true,
		show_close_icon = false,
		show_tab_indicators = true,
		persist_buffer_sort = true,
		separator_style = "thin",
		enforce_regular_tabs = false,
		always_show_bufferline = false,
		hover = {
			enabled = false,
			delay = 200,
			reveal = { "close" },
		},
		sort_by = "id",
		debug = { logging = false },
	},
})
