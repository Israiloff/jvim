local M = {}

local logger = require("io.github.israiloff.config.logger")
local logger_name = "io.github.israiloff.config.copilot-utils"

local function normalize_path(path)
	if not path or path == "" then
		return path
	end

	return vim.fs.normalize(path)
end

function M.ensure_copilot_workspace_folder(path)
	path = normalize_path(path)

	if not path or path == "" then
		logger.debug(logger_name, "Copilot workspace path is empty, skip update")
		return
	end

	local current = vim.g.copilot_workspace_folders
	if type(current) ~= "table" then
		current = {}
	end

	for _, existing in ipairs(current) do
		if normalize_path(existing) == path then
			logger.debug(logger_name, "Copilot workspace already contains: " .. path)
			return
		end
	end

	table.insert(current, path)
	vim.g.copilot_workspace_folders = current
    vim.b.workspace_folder = path
	logger.info(logger_name, "Copilot workspace added: " .. path)
end

return M
