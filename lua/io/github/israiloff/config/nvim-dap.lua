local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
	print("Error: 'io.github.israiloff.config.logger' not found")
	return
end

local dap_status, _ = pcall(require, "dap")

if not dap_status then
	log.error("'nvim.dap' not found")
	return
end
