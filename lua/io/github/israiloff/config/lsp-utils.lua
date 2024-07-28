local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
	print("Error: 'io.github.israiloff.config.logger' not found. LSP will not be configured.")
	return
end

local logger_name = "io.github.israiloff.config.lsp-utils"

Utils = {}

local reg_status, registry = pcall(require, "mason-registry")
local ml_status, mason_lspconfig = pcall(require, "mason-lspconfig")

function Utils.install_package(package_name)
	log.info(logger_name, "install_package started for package '" .. package_name .. "'.")

	if not reg_status then
		log.error(logger_name, "'mason-registry' not found. Aborting install_package.")
		return false
	end

	if not registry.has_package(package_name) then
		vim.notify("Package " .. package_name .. " is not available in the Mason registry.", vim.log.levels.ERROR)
		return false
	end

	local pkg = registry.get_package(package_name)

	if pkg.is_installed(pkg) then
		log.warn(logger_name, "Package " .. package_name .. " is already installed.")
		return true
	end

	log.info(logger_name, "Installing package '" .. package_name .. "'...")

	local install_status, _ = pcall(function()
		pkg.install(pkg)
	end)

	log.info(logger_name, "install_package finished for package '" .. package_name .. "'.")
	return install_status
end

function Utils.get_available_servers(filter)
	if not reg_status then
		log.error(logger_name, "'mason-registry' not found. Aborting get_supported_servers.")
		return
	end

	if not ml_status then
		log.error(logger_name, "'mason-lspconfig' not found. Aborting get_supported_servers.")
		return
	end

	registry.refresh()

	local ss_status, supported_servers = pcall(function()
		return mason_lspconfig.get_available_servers(filter)
	end)

	if not ss_status or not supported_servers then
		log.error(logger_name, "Error getting supported servers.")
		return {}
	end

	return supported_servers
end

function Utils.already_installed_all(available)
	if not reg_status then
		log.error(logger_name, "'mason-registry' not found. Aborting already_installed.")
		return false
	end

	for _, server in ipairs(available) do
		if registry.is_installed(server) then
			return true
		end
	end
	return false
end

return Utils
