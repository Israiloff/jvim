-- Read/write access to `properties-local.lua` — the per-machine override file
-- that `properties.lua` merges over its defaults at startup.
--
-- Both the AI provider switch and the Spring Boot toggle persist their choice
-- here, so the loading, validation and serialization live in one place instead
-- of being duplicated per feature.

local M = {}

local path = vim.fn.stdpath("config") .. "/lua/io/github/israiloff/config/properties-local.lua"

local function notify(message, level, title)
	vim.notify(message, level, { title = title or "JVIM" })
end

function M.path()
	return path
end

function M.exists()
	local uv = vim.uv or vim.loop
	return uv.fs_stat(path) ~= nil
end

---@param title string|nil notification title, so errors name the calling feature
---@return table
function M.read(title)
	if not M.exists() then
		return {}
	end

	local chunk, load_err = loadfile(path)
	if not chunk then
		notify("Failed to load local properties: " .. load_err, vim.log.levels.ERROR, title)
		return {}
	end

	local ok, local_properties = pcall(chunk)
	if not ok then
		notify("Failed to evaluate local properties: " .. local_properties, vim.log.levels.ERROR, title)
		return {}
	end

	if type(local_properties) ~= "table" then
		notify("Local properties must return a table: " .. path, vim.log.levels.ERROR, title)
		return {}
	end

	return local_properties
end

---@param local_properties table
---@param title string|nil
---@return boolean written
function M.write(local_properties, title)
	if type(local_properties) ~= "table" then
		notify("Local properties payload must be a table.", vim.log.levels.ERROR, title)
		return false
	end

	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")

	local file, open_err = io.open(path, "w")
	if not file then
		notify("Failed to open local properties: " .. open_err, vim.log.levels.ERROR, title)
		return false
	end

	local ok, write_err = file:write("return " .. vim.inspect(local_properties) .. "\n")
	file:close()

	if not ok then
		notify("Failed to write local properties: " .. tostring(write_err), vim.log.levels.ERROR, title)
		return false
	end

	return true
end

-- Sets one nested value and persists the file, leaving every other key alone.
-- Intermediate tables are created as needed, so `set({"spring","enabled"}, ...)`
-- works against an empty or partial override file.
---@param keys string[] path to the value, e.g. { "spring", "enabled" }
---@param value any
---@param title string|nil
---@return boolean written
function M.set(keys, value, title)
	local local_properties = M.read(title)
	local node = local_properties

	for index = 1, #keys - 1 do
		if type(node[keys[index]]) ~= "table" then
			node[keys[index]] = {}
		end
		node = node[keys[index]]
	end

	node[keys[#keys]] = value

	return M.write(local_properties, title)
end

return M
