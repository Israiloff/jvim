local M = {}
_G.TAB = "    "
local properties = require("io.github.israiloff.config.properties")

function M.debug(logger, text)
	if not properties.logger.level.debug then
		return
	end
	CM_LOGGER("DEBUG", text, logger)
end

function M.info(logger, text)
	if not properties.logger.level.info then
		return
	end
	CM_LOGGER("INFO", text, logger)
end

function M.warn(logger, text)
	if not properties.logger.level.warn then
		return
	end
	CM_LOGGER("WARN", text, logger)
end

function M.error(logger, ex)
	if not properties.logger.level.error then
		return
	end
	CM_LOGGER("ERROR", ex, logger)
end

function _G.CM_LOGGER(level, text, logger)
	if
		properties.logger.enabled
		and (
			vim.tbl_contains(properties.logger.enabled_loggers, "*")
			or vim.tbl_contains(properties.logger.enabled_loggers, logger)
		)
	then
		vim.notify(
			vim.fn.strftime("%Y-%m-%d %H:%M:%S") .. TAB .. "[" .. level .. "]" .. TAB .. logger .. TAB .. text,
			level,
			{ title = logger }
		)
	end
end

return M
