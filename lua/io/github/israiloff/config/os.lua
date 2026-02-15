local logger_status, logger = pcall(require, "io.github.israiloff.config.logger")

if not logger_status then
	print("JAVA: io.github.israiloff.config.logger not found, please install it and try again")
	return
end

local logger_name = "io.github.israiloff.config.os"

---@class OS
---@field WINDOWS string Operating System name for Windows
---@field LINUX string Operating System name for Linux
---@field MAC string Operating System name for macOS
----- This module provides functions to determine the current operating system
------@field get_current_os fun(): string Returns the current operating system as a constant
------@field get_current_os_name fun(): string Returns the real name of the current operating system
------@field is_windows fun(os_real_name?: string): boolean Checks if the current operating system is Windows
------@field is_linux fun(os_real_name?: string): boolean Checks if the current operating system is Linux
------@field is_mac fun(os_real_name?: string): boolean Checks if the current operating system is macOS
OS = {
	WINDOWS = "win",
	LINUX = "linux",
	MAC = "mac",
}

-- Returns the current operating system
-- -- This function checks the real name of the operating system and returns a constant
-- -- representing the operating system type.
-- -- @return string The constant representing the current operating system
function OS.get_current_os()
	logger.debug(logger_name, "OS: determining current operating system...")

	local os_real_name = OS.get_current_os_name()
	logger.debug(logger_name, "OS: real name is '" .. os_real_name .. "'")

	if OS.is_mac(os_real_name) then
		return OS.MAC
	elseif OS.is_windows(os_real_name) then
		return OS.WINDOWS
	elseif OS.is_linux(os_real_name) then
		return OS.LINUX
	end

	logger.error(logger_name, "OS: unknown operating system '" .. os_real_name .. "', defaulting to linux")
	return OS.LINUX
end

-- Returns the real name of the operating system
-- -- This function retrieves the real name of the current operating system
-- -- using the `$OS` environment variable.
-- -- @return string The real name of the current operating system
function OS.get_current_os_name()
	return string.lower((vim.uv or vim.loop).os_uname().sysname)
end

-- Check if the current operating system is Windows
-- -- @param os_real_name (optional) the real name of the operating system (default is obtained from `OS.get_current_os_name()`)
-- -- This function checks if the current operating system is Windows
-- -- by matching the real name against common Windows identifiers.
-- -- @return boolean True if the current operating system is Windows, false otherwise
function OS.is_windows(os_real_name)
	return string.match(os_real_name, "win")
end

-- Check if the current operating system is Linux
-- -- @param os_real_name (optional) the real name of the operating system (default is obtained from `OS.get_current_os_name()`)
-- -- This function checks if the current operating system is Linux
-- -- by matching the real name against common Linux identifiers.
-- -- @return boolean True if the current operating system is Linux, false otherwise
function OS.is_linux(os_real_name)
	return string.match(os_real_name, "linux") or string.match(os_real_name, "unix")
end

-- Check if the current operating system is macOS
-- -- @param os_real_name (optional) the real name of the operating system (default is obtained from `OS.get_current_os_name()`)
-- -- This function checks if the current operating system is macOS
-- -- by matching the real name against common macOS identifiers.
-- -- @return boolean True if the current operating system is macOS, false otherwise
function OS.is_mac(os_real_name)
	return string.match(os_real_name, "mac") or string.match(os_real_name, "darwin")
end

return OS
