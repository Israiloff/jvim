local icons = require("io.github.israiloff.config.icons")
local null_ls = require("null-ls")
local null_ls_sources = require("null-ls.sources")

---@diagnostic disable: param-type-mismatch
local nvim_tree_shift = {
	function()
		local len = vim.api.nvim_win_get_width(require("nvim-tree.view").get_winnr()) - 1
		local title = "Nvim-Tree"
		local left = (len - #title) / 2
		local right = len - left - #title
		return string.rep(" ", left) .. title .. string.rep(" ", right)
	end,
	cond = require("nvim-tree.view").is_visible,
	color = "Normal",
}

local function get_providers(filetype)
	local available_sources = null_ls_sources.get_available(filetype)
	local registered = {}
	for _, source in ipairs(available_sources) do
		for method in pairs(source.methods) do
			registered[method] = registered[method] or {}
			table.insert(registered[method], source.name)
		end
	end
	return registered
end

local function get_registered_linters(filetype)
	return vim.iter(vim.tbl_map(function(m)
		return get_providers(filetype)[m] or {}
	end, {
		null_ls.methods.DIAGNOSTICS,
		null_ls.methods.DIAGNOSTICS_ON_OPEN,
		null_ls.methods.DIAGNOSTICS_ON_SAVE,
	}))
		:flatten()
		:totable()
end

require("lualine").setup({
	options = {
		icons_enabled = true,
		component_separators = {
			left = "",
			right = "",
		},
		section_separators = {
			left = "",
			right = "",
		},
		disabled_filetypes = {
			"NvimTree",
			"TelescopePrompt",
			"packer",
			"toggleterm",
		},
		always_divide_middle = true,
		globalstatus = true,
	},
	sections = {
		lualine_a = {
			nvim_tree_shift,
			{
				function()
					return "%#SLNvimIcon#" .. icons.ui.Neovim .. "%*"
				end,
				padding = { left = 2, right = 2 },
			},
		},
		lualine_b = {
			{
				function()
					local branch = vim.b.gitsigns_head
					if not branch or branch == "" then
						return ""
					end
					return "%#SLGitIcon#" .. icons.git.Branch .. " " .. "%#SLGitBranchName#" .. branch .. "%*"
				end,
				padding = { left = 1, right = 1 },
			},
		},
		lualine_c = {
			{
				"diff",
				source = function()
					local gitsigns = vim.b.gitsigns_status_dict
					if gitsigns then
						return {
							added = gitsigns.added,
							modified = gitsigns.changed,
							removed = gitsigns.removed,
						}
					end
				end,
				symbols = {
					added = icons.git.LineAdded .. " ",
					modified = icons.git.LineModified .. " ",
					removed = icons.git.LineRemoved .. " ",
				},
				padding = { left = 2, right = 1 },
				cond = nil,
			},
		},
		lualine_x = {
			{
				"diagnostics",
				sources = { "nvim_diagnostic" },
				symbols = {
					error = icons.diagnostics.BoldError .. " ",
					warn = icons.diagnostics.BoldWarning .. " ",
					info = icons.diagnostics.BoldInformation .. " ",
					hint = icons.diagnostics.BoldHint .. " ",
				},
			},
			{
				function()
					local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
					if #buf_clients == 0 then
						return "LSP Inactive"
					end

					local buf_ft = vim.bo.filetype
					local buf_client_names = {}
					local copilot_active = false

					for _, client in pairs(buf_clients) do
						if client.name ~= "null-ls" and client.name ~= "GitHub Copilot" then
							table.insert(buf_client_names, client.name)
						end

						if client.name == "GitHub Copilot" then
							copilot_active = true
						end
					end

					vim.list_extend(buf_client_names, get_providers(buf_ft)[null_ls.methods.FORMATTING] or {})
					vim.list_extend(buf_client_names, get_registered_linters(buf_ft))

					for i, name in ipairs(buf_client_names) do
						if icons.lsp[name] then
							buf_client_names[i] = "%#SLIcon_" .. name .. "#" .. icons.lsp[name] .. "%*"
						end
					end

					local unique_client_names = table.concat(buf_client_names, " ")
					local language_servers = string.format("%s", unique_client_names)

					if copilot_active then
						language_servers = language_servers .. " " .. "%#SLCopilotIcon#" .. icons.ui.Copilot .. "%*"
					end

					return language_servers
				end,
				color = nil,
				cond = function()
					return vim.o.columns > 100
				end,
			},
			"encoding",
			"filetype",
		},
		lualine_y = { "location" },
		lualine_z = {
			function()
				return "%#SLClock#" .. icons.ui.Clock .. " " .. os.date("%H:%M:%S") .. "%*"
			end,
		},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
})
