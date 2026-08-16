local M = {}
_G.TAB = "    "
local properties = require("io.github.israiloff.config.properties")

-- `vim.notify` expects a numeric level from `vim.log.levels`. Passing the bare
-- string ("ERROR", "WARN", ...) made every message fall through to the plain
-- `else` branch of the default notify handler, so errors rendered like info.
local levels = {
	DEBUG = vim.log.levels.DEBUG,
	INFO = vim.log.levels.INFO,
	WARN = vim.log.levels.WARN,
	ERROR = vim.log.levels.ERROR,
}

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
		-- Callers occasionally forget the `logger` argument (`log.error("boom")`),
		-- which used to blow up on a nil concat the moment logging was enabled.
		-- Tolerate it instead of turning a log line into a crash.
		if text == nil then
			text, logger = logger, "unknown"
		end

		-- The activity panel renders the timestamp, the level and the source
		-- itself, so baking them into the message would print each of them
		-- twice. Only pre-format when the message is going somewhere that shows
		-- nothing but the raw string.
		local activity = (properties.gui or {}).activity or {}
		local panel_formats = activity.enabled ~= false and activity.notify ~= false

		local message = tostring(text)
		if not panel_formats then
			message = vim.fn.strftime("%Y-%m-%d %H:%M:%S")
				.. TAB
				.. "["
				.. level
				.. "]"
				.. TAB
				.. tostring(logger)
				.. TAB
				.. message
		end

		vim.notify(message, levels[level] or vim.log.levels.INFO, { title = tostring(logger) })
	end
end

return M
