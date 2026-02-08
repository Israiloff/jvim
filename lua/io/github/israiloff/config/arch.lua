local logger_status, logger = pcall(require, "io.github.israiloff.config.logger")

if not logger_status then
	print("JAVA: io.github.israiloff.config.logger not found, please install it and try again")
	return
end

local logger_name = "io.github.israiloff.config.arch"

---@class ARCH
---@field ARM string Architecture name for ARM
---@field X86_64 string Architecture name for x86_64
----- This module provides functions to determine the current architecture
------@field get_architecture fun(): string Returns the current architecture as a constant
------@field get_architecture_name fun(): string Returns the real name of the current architecture
local ARCH = {
	ARM = "arm",
	X86_64 = "x86_64",
}

-- Returns the current architecture
-- -- This function checks the real name of the architecture and returns a constant
-- representing the architecture type.
-- @return string The constant representing the current architecture
function ARCH.get_architecture()
	logger.debug(logger_name, "ARCH: determining current architecture...")

	local arch = ARCH.get_architecture_name()

	logger.debug(logger_name, "ARCH: real name is '" .. arch .. "'")

	if string.match(arch, "arm") or string.match(arch, "aarch64") then
		return ARCH.ARM
	elseif string.match(arch, "x86_64") or string.match(arch, "amd64") then
		return ARCH.X86_64
	else
		logger.error(logger_name, "ARCH: unknown architecture '" .. arch .. "', defaulting to x86_64")
		return ARCH.X86_64 -- Default to x86_64 if architecture is unknown
	end
end

-- Returns the real name of the architecture
-- -- This function retrieves the real name of the current architecture
-- using the `machine` field from the `os_uname` function.
-- @return string The real name of the current architecture
function ARCH.get_architecture_name()
	return string.lower(vim.uv.os_uname().machine)
end

return ARCH
