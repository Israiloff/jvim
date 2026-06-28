local M = {}

local properties = require("io.github.israiloff.config.properties")

M.providers = {
	COPILOT = "copilot",
	TABBY = "tabby",
	NONE = "none",
}

local valid_providers = {
	[M.providers.COPILOT] = true,
	[M.providers.TABBY] = true,
	[M.providers.NONE] = true,
}

local valid_tabby_triggers = {
	auto = true,
	manual = true,
}

local local_properties_path = vim.fn.stdpath("config") .. "/lua/io/github/israiloff/config/properties-local.lua"

local function file_exists(path)
	local uv = vim.uv or vim.loop
	return uv.fs_stat(path) ~= nil
end

local function is_valid_provider(provider)
	return valid_providers[provider] == true
end

local function normalize_provider(provider)
	if is_valid_provider(provider) then
		return provider
	end

	return M.providers.COPILOT
end

local function normalize_tabby_trigger(trigger)
	if valid_tabby_triggers[trigger] then
		return trigger
	end

	return "auto"
end

local function serialize_lua_table(tbl)
	return "return " .. vim.inspect(tbl) .. "\n"
end

function M.get_local_properties_path()
	return local_properties_path
end

function M.get_provider()
	return normalize_provider(properties.ai and properties.ai.provider)
end

function M.get_runtime_provider()
	return M.get_provider()
end

function M.get_provider_label(provider)
	local labels = {
		[M.providers.COPILOT] = "Copilot",
		[M.providers.TABBY] = "Tabby",
		[M.providers.NONE] = "Disabled",
	}

	return labels[normalize_provider(provider)]
end

function M.is(provider)
	return M.get_provider() == provider
end

function M.read_local_properties()
	if not file_exists(local_properties_path) then
		return {}
	end

	local chunk, load_err = loadfile(local_properties_path)
	if not chunk then
		vim.notify("Failed to load local properties: " .. load_err, vim.log.levels.ERROR, { title = "JVIM AI" })
		return {}
	end

	local ok, local_properties = pcall(chunk)
	if not ok then
		vim.notify("Failed to evaluate local properties: " .. local_properties, vim.log.levels.ERROR, { title = "JVIM AI" })
		return {}
	end

	if type(local_properties) ~= "table" then
		vim.notify("Local properties must return a table: " .. local_properties_path, vim.log.levels.ERROR, { title = "JVIM AI" })
		return {}
	end

	return local_properties
end

function M.get_configured_provider()
	local local_properties = M.read_local_properties()
	local local_ai = local_properties.ai

	if type(local_ai) ~= "table" or local_ai.provider == nil then
		return M.get_runtime_provider()
	end

	return normalize_provider(local_ai.provider)
end

function M.get_tabby_agent_start_command()
	local tabby_config = properties.ai and properties.ai.tabby
	local command = tabby_config and tabby_config.agent_start_command

	if type(command) ~= "table" or vim.tbl_isempty(command) then
		return { "npx", "tabby-agent", "--stdio" }
	end

	return vim.deepcopy(command)
end

function M.get_tabby_inline_completion_trigger()
	local tabby_config = properties.ai and properties.ai.tabby
	return normalize_tabby_trigger(tabby_config and tabby_config.inline_completion_trigger)
end

function M.write_local_properties(local_properties)
	if type(local_properties) ~= "table" then
		vim.notify("Local properties payload must be a table.", vim.log.levels.ERROR, { title = "JVIM AI" })
		return false
	end

	local dir = vim.fn.fnamemodify(local_properties_path, ":h")
	vim.fn.mkdir(dir, "p")

	local file, open_err = io.open(local_properties_path, "w")
	if not file then
		vim.notify("Failed to open local properties: " .. open_err, vim.log.levels.ERROR, { title = "JVIM AI" })
		return false
	end

	local ok, write_err = file:write(serialize_lua_table(local_properties))
	file:close()

	if not ok then
		vim.notify("Failed to write local properties: " .. tostring(write_err), vim.log.levels.ERROR, { title = "JVIM AI" })
		return false
	end

	return true
end

function M.select_provider(provider)
	if not is_valid_provider(provider) then
		vim.notify("Unsupported AI provider: " .. tostring(provider), vim.log.levels.ERROR, { title = "JVIM AI" })
		return
	end

	local local_properties = M.read_local_properties()
	local local_ai = local_properties.ai

	if type(local_ai) ~= "table" then
		local_ai = {}
		local_properties.ai = local_ai
	end

	local_ai.provider = provider

	if not M.write_local_properties(local_properties) then
		return
	end

	vim.notify(
		"AI provider for the next Neovim start: " .. M.get_provider_label(provider) .. ". Restart Neovim to apply.",
		vim.log.levels.INFO,
		{ title = "JVIM AI" }
	)
end

function M.edit_local_properties()
	if not file_exists(local_properties_path) then
		if not M.write_local_properties({
			ai = {
				provider = M.get_runtime_provider(),
			},
		}) then
			return
		end
	end

	vim.cmd("edit " .. vim.fn.fnameescape(local_properties_path))
end

function M.show_status()
	local runtime_provider = M.get_runtime_provider()
	local configured_provider = M.get_configured_provider()

	vim.notify(
		table.concat({
			"Current session: " .. M.get_provider_label(runtime_provider),
			"Next start: " .. M.get_provider_label(configured_provider),
			"Local override: " .. (file_exists(local_properties_path) and local_properties_path or "not created"),
		}, "\n"),
		vim.log.levels.INFO,
		{ title = "JVIM AI" }
	)
end

if vim.fn.exists(":JvimAiSelect") == 0 then
	vim.api.nvim_create_user_command("JvimAiSelect", function(opts)
		M.select_provider(opts.args)
	end, {
		nargs = 1,
		complete = function()
			return { M.providers.COPILOT, M.providers.TABBY, M.providers.NONE }
		end,
		desc = "Select AI provider for the next Neovim start",
	})
end

if vim.fn.exists(":JvimAiStatus") == 0 then
	vim.api.nvim_create_user_command("JvimAiStatus", function()
		M.show_status()
	end, {
		desc = "Show active and configured AI provider",
	})
end

return M
