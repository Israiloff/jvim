local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
	print("Error: 'io.github.israiloff.config.logger' not found")
	return
end

local logger_name = "io.github.israiloff.config.nvim-navic"

local icons_status, icons = pcall(require, "io.github.israiloff.config.icons")

if not icons_status then
	log.error(logger_name, "'io.github.israiloff.config.icons' not found")
	return
end

local navic_status, navic = pcall(require, "nvim-navic")

if not navic_status then
	log.error(logger_name, "'nvim-navic' not found")
	return
end

local utils_status, utils = pcall(require, "io.github.israiloff.config.utils")

if not utils_status then
	log.error(logger_name, "'io.github.israiloff.config.utils' not found")
	return
end

-- vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

local winbar_filetype_exclude = {
	"help",
	"startify",
	"dashboard",
	"lazy",
	"neo-tree",
	"neogitstatus",
	"NvimTree",
	"Trouble",
	"alpha",
	"lir",
	"Outline",
	"spectre_panel",
	"toggleterm",
	"DressingSelect",
	"Jaq",
	"harpoon",
	"dap-repl",
	"dap-terminal",
	"dapui_console",
	"dapui_hover",
	"lab",
	"notify",
	"noice",
	"neotest-summary",
	"",
}

M = {}

function M.attach(client, bufnr)
	navic.attach(client, bufnr)
end

local function get_filename()
	log.debug(logger_name, "get_filename started")

	local filename = vim.fn.expand("%:t")
	local extension = vim.fn.expand("%:e")

	if not utils.isempty(filename) then
		local file_icon, hl_group
		local devicons_ok, devicons = pcall(require, "nvim-web-devicons")

		if devicons_ok then
			file_icon, hl_group = devicons.get_icon(filename, extension, { default = true })

			if utils.isempty(file_icon) then
				file_icon = icons.kind.File
			end
		else
			file_icon = ""
			hl_group = "Normal"
		end

		local buf_ft = vim.bo.filetype

		if buf_ft == "dapui_breakpoints" then
			file_icon = icons.ui.Bug
		end

		if buf_ft == "dapui_stacks" then
			file_icon = icons.ui.Stacks
		end

		if buf_ft == "dapui_scopes" then
			file_icon = icons.ui.Scopes
		end

		if buf_ft == "dapui_watches" then
			file_icon = icons.ui.Watches
		end

		local navic_text_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
		vim.api.nvim_set_hl(0, "Winbar", { fg = navic_text_hl.fg })

		return " " .. "%#" .. hl_group .. "#" .. file_icon .. "%*" .. " " .. "%#Winbar#" .. filename .. "%*"
	end
end

local function get_gps()
	log.debug(logger_name, "get_gps started")
	local status_gps_ok, gps = pcall(require, "nvim-navic")
	if not status_gps_ok then
		return ""
	end

	local status_ok, gps_location = pcall(gps.get_location, {})
	if not status_ok then
		return ""
	end

	if not gps.is_available() or gps_location == "error" then
		return ""
	end

	if not utils.isempty(gps_location) then
		return "%#NavicSeparator#" .. icons.ui.ChevronRight .. "%* " .. gps_location
	else
		return ""
	end
end

local function excludes()
	log.debug(logger_name, "getting excludes")
	return vim.tbl_contains(winbar_filetype_exclude or {}, vim.bo.filetype)
end

local function get_winbar()
	log.debug(logger_name, "get_winbar started")

	if excludes() then
		log.debug(logger_name, "buffer is in exclude list")
		return
	end

	local value = get_filename()

	local gps_added = false

	if not utils.isempty(value) then
		local gps_value = get_gps()
		value = value .. " " .. gps_value
		if not utils.isempty(gps_value) then
			gps_added = true
		end
	end

	if not utils.isempty(value) and vim.api.nvim_get_option_value("mod", { buf = 0 }) then
		local mod = "%#LspCodeLens#" .. icons.ui.Circle .. "%*"
		if gps_added then
			value = value .. " " .. mod
		else
			value = value .. mod
		end
	end

	local num_tabs = #vim.api.nvim_list_tabpages()

	if num_tabs > 1 and not utils.isempty(value) then
		local tabpage_number = tostring(vim.api.nvim_tabpage_get_number(0))
		value = value .. "%=" .. tabpage_number .. "/" .. tostring(num_tabs)
	end

	local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", value, { scope = "local" })
	if not status_ok then
		return
	end

	log.debug(logger_name, "winbar successfully set")
end

local function create_winbar()
	vim.api.nvim_create_augroup("_winbar", {})
	vim.api.nvim_create_autocmd({
		"CursorHoldI",
		"CursorHold",
		"BufWinEnter",
		"BufFilePost",
		"InsertEnter",
		"BufWritePost",
		"TabClosed",
		"TabEnter",
	}, {
		group = "_winbar",
		callback = function()
			local status_ok, _ = pcall(vim.api.nvim_buf_get_var, 0, "lsp_floating_window")
			if not status_ok then
				get_winbar()
			end
		end,
	})
end

create_winbar()

navic.setup({
	icons = {
		Array = icons.kind.Array .. " ",
		Boolean = icons.kind.Boolean .. " ",
		Class = icons.kind.Class .. " ",
		Color = icons.kind.Color .. " ",
		Constant = icons.kind.Constant .. " ",
		Constructor = icons.kind.Constructor .. " ",
		Enum = icons.kind.Enum .. " ",
		Enummber = icons.kind.EnumMember .. " ",
		Event = icons.kind.Event .. " ",
		Field = icons.kind.Field .. " ",
		File = icons.kind.File .. " ",
		Folder = icons.kind.Folder .. " ",
		Function = icons.kind.Function .. " ",
		Interface = icons.kind.Interface .. " ",
		Key = icons.kind.Key .. " ",
		Keyword = icons.kind.Keyword .. " ",
		thod = icons.kind.Method .. " ",
		dule = icons.kind.Module .. " ",
		Namespace = icons.kind.Namespace .. " ",
		Null = icons.kind.Null .. " ",
		Number = icons.kind.Number .. " ",
		Object = icons.kind.Object .. " ",
		Operator = icons.kind.Operator .. " ",
		Package = icons.kind.Package .. " ",
		Property = icons.kind.Property .. " ",
		Reference = icons.kind.Reference .. " ",
		Snippet = icons.kind.Snippet .. " ",
		String = icons.kind.String .. " ",
		Struct = icons.kind.Struct .. " ",
		Text = icons.kind.Text .. " ",
		TypeParameter = icons.kind.TypeParameter .. " ",
		Unit = icons.kind.Unit .. " ",
		Value = icons.kind.Value .. " ",
		Variable = icons.kind.Variable .. " ",
	},
	highlight = true,
	separator = " " .. icons.ui.ChevronRight .. " ",
	depth_limit = 0,
	depth_limit_indicator = "..",
})

return M
