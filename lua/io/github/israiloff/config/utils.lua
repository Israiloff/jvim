M = {}
local logger = require("io.github.israiloff.config.logger")
local file_name = vim.fn.expand("<sfile>:p")

function M.file_exists(path)
	logger.debug(file_name, "Checking if file exists: " .. path)
	local file = io.open(path, "r")
	if file then
		file:close()
		return true
	else
		return false
	end
end

function M.download(url, path)
	logger.debug(file_name, "Downloading " .. url .. " to " .. path)
	local cmd = string.format("curl -fLo %s --create-dirs %s", path, url)
	os.execute(cmd)
end

function M.download_if_missing(file_path, file_url)
	logger.debug(file_name, "Downloading if missing: " .. file_path)
	if not M.file_exists(file_path) then
		M.download(file_url, file_path)
	end

	return file_path
end

function M.create_dirs(path)
	logger.debug(file_name, "Creating directories: " .. path)
	vim.fn.mkdir(path, "p")
end

return M
