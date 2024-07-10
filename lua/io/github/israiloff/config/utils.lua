M = {}

function M.file_exists(path)
	local file = io.open(path, "r")
	if file then
		file:close()
		return true
	else
		return false
	end
end

function M.download(url, path)
	local cmd = string.format("curl -fLo %s --create-dirs %s", path, url)
	os.execute(cmd)
end

function M.download_if_missing(file_path, file_url)
	print("download_if_missing started with file_path: " .. file_path .. " and file_url: " .. file_url)
	if not M.file_exists(file_path) then
		print("Downloading " .. file_url .. " to " .. file_path)
		M.download(file_url, file_path)
	end

	return file_path
end

function M.create_dirs(path)
	print("Creating directories: " .. path)
	vim.fn.mkdir(path, "p")
end

return M
