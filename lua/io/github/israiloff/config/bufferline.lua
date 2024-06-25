local icons = require("io.github.israiloff.config.icons")

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
		close_command = function(bufnr)
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
