local M = {}

local logger = require("io.github.israiloff.config.logger")
local logger_name = "io.github.israiloff.config.utils"

local uv = vim.uv or vim.loop
local curl_status, curl = pcall(require, "plenary.curl")

local function file_stat(path)
	return uv.fs_stat(path)
end

local function file_exists_and_nonempty(path)
	local st = file_stat(path)
	return st ~= nil and st.type == "file" and (st.size or 0) > 0
end

local function download(url, path)
	logger.debug(logger_name, ("Downloading %s -> %s"):format(url, path))

	if not curl_status then
		logger.error(logger_name, "plenary.curl not found; cannot download: " .. url)
		return false
	end

	local res = curl.get(url, { output = path })
	if res and res.status == 200 and file_exists_and_nonempty(path) then
		logger.debug(logger_name, "Downloaded OK: " .. path)
		return true
	end

	logger.error(logger_name, ("Failed to download (%s): %s"):format(tostring(res and res.status), url))
	return false
end

function M.download_if_missing(file_path, file_url)
	logger.debug(logger_name, ("download_if_missing: %s"):format(file_path))

	if file_exists_and_nonempty(file_path) then
		return true, file_path
	end

	M.create_dirs(vim.fn.fnamemodify(file_path, ":h"))
	local ok = download(file_url, file_path)
	return ok, file_path
end

function M.create_dirs(path)
	if not path or path == "" then
		return
	end
	vim.fn.mkdir(path, "p")
end

function M.isempty(s)
	return s == nil or s == ""
end

function M.get_java_path()
	local java_home = vim.fn.getenv("JAVA_HOME")
	if java_home ~= vim.NIL and java_home ~= "" then
		local p = java_home .. "/bin/java"
		if file_exists_and_nonempty(p) or vim.fn.executable(p) == 1 then
			return p
		end
	end

	-- fallback to PATH
	if vim.fn.executable("java") == 1 then
		return "java"
	end

	-- last resort: common paths
	local common_paths = {
		"/usr/bin/java",
		"/usr/local/bin/java",
		"/opt/java/bin/java",
	}
	for _, path in ipairs(common_paths) do
		if vim.fn.executable(path) == 1 then
			return path
		end
	end

	logger.error(logger_name, "Java not found in JAVA_HOME, PATH, or common locations")
	return nil
end

function M.get_ftplugin_filetypes()
	local ftplugin_filetypes = {}
	local ftplugin_dir = vim.fn.stdpath("config") .. "/ftplugin"
	local ftplugin_files = vim.fn.glob(ftplugin_dir .. "/*.lua", false, true)
	for _, file in ipairs(ftplugin_files) do
		local filetype = vim.fn.fnamemodify(file, ":t:r")
		table.insert(ftplugin_filetypes, filetype)
	end
	return ftplugin_filetypes
end

return M
