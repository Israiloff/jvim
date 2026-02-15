local M = {}

local utils = require("io.github.israiloff.config.utils")
local logger = require("io.github.israiloff.config.logger")
local logger_name = "io.github.israiloff.config.java.lombok"

M.lombok_path = vim.fn.stdpath("data") .. "/lombok.jar"
local lombok_url = "https://projectlombok.org/downloads/lombok.jar"

function M.setup()
	local ok, path = utils.download_if_missing(M.lombok_path, lombok_url)
	if not ok then
		logger.error(logger_name, "Failed to ensure lombok.jar; continuing without -javaagent")
		return false, path
	end
	return true, path
end

return M
