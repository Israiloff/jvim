local M = {}
_G.TAB = "    "

function M.debug(logger, text)
	if not require("io.github.israiloff.config.properties").logger.level.debug then
		return
	end
	CM_LOGGER("DEBUG", text, logger)
end

function M.info(logger, text)
	if not require("io.github.israiloff.config.properties").logger.level.info then
		return
	end
	CM_LOGGER("INFO", text, logger)
end

function M.warn(logger, text)
	if not require("io.github.israiloff.config.properties").logger.level.warn then
		return
	end
	CM_LOGGER("WARN", text, logger)
end

function M.error(logger, ex)
	if not require("io.github.israiloff.config.properties").logger.level.error then
		return
	end
	CM_LOGGER("ERROR", ex, logger)
end

function _G.CM_LOGGER(level, text, logger)
	if not require("io.github.israiloff.config.properties").logger.enabled then
		return
	end
	print(vim.fn.strftime("%Y-%m-%d %H:%M:%S") .. TAB .. "[" .. level .. "]" .. TAB .. logger .. TAB .. text)
end

return M
