local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
	print("Error: 'io.github.israiloff.config.logger' not found. LSP will not be configured.")
	return
end

local logger_name = "io.github.israiloff.config.mason-lspconfig"

local lsp_status, mason_lspconfig = pcall(require, "mason-lspconfig")

if not lsp_status then
	log.error(logger_name, "'mason-lspconfig' not found. LSP auto installation will not be configured.")
	return
end

log.info(logger_name, "Setting up Mason LSPConfig")

mason_lspconfig.setup({
	ensure_installed = {
		"lua_ls",
		"jdtls",
	},
	automatic_installation = {
		enabled = true,
		exclude = {
			"lemminx",
		},
	},
	handlers = {
		function(server_name)
			require("lspconfig")[server_name].setup({
				on_attach = function(client, bufnr)
					vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
					local navic_status, navic = pcall(require, "nvim-navic")
					if navic_status then
						navic.attach(client, bufnr)
					end
				end,
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
				flags = { debounce_text_changes = 200 },
			})
		end,
	},
})

local utils_status, utils = pcall(require, "io.github.israiloff.config.lsp-utils")

if not utils_status then
	log.error(
		logger_name,
		"'io.github.israiloff.config.utils' not found. Filetype auto resolve will not be configured."
	)
	return
end

log.info(logger_name, "Setting up Mason LSPConfig filetype auto resolve")

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		local filetype = vim.bo.filetype
		local availables = utils.get_available_servers({ filetype = filetype })

		log.info(logger_name, "Available servers for '" .. filetype .. "' : " .. vim.inspect(availables))

		if #availables == 0 or availables == nil then
			log.warn(logger_name, "No available servers for " .. filetype)
			return
		end

		if utils.already_installed(availables) then
			log.info(logger_name, "Server for '" .. filetype .. "' already installed")
			return
		end

		for _, server in ipairs(availables) do
			log.info(logger_name, "Server: " .. vim.inspect(server))
			if Utils.install_package(server) then
				log.info(logger_name, "Server for '" .. filetype .. "' installed successfully")
				break
			end
		end
	end,
})
