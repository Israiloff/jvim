local M = {}

local properties = require("io.github.israiloff.config.properties")
local local_properties = require("io.github.israiloff.config.local-properties")

local TITLE = "JVIM AI"

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

function M.get_local_properties_path()
	return local_properties.path()
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
	return local_properties.read(TITLE)
end

function M.get_configured_provider()
	local local_ai = M.read_local_properties().ai

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

function M.write_local_properties(payload)
	return local_properties.write(payload, TITLE)
end

function M.select_provider(provider)
	if not is_valid_provider(provider) then
		vim.notify("Unsupported AI provider: " .. tostring(provider), vim.log.levels.ERROR, { title = TITLE })
		return
	end

	if not local_properties.set({ "ai", "provider" }, provider, TITLE) then
		return
	end

	vim.notify(
		"AI provider for the next Neovim start: " .. M.get_provider_label(provider) .. ". Restart Neovim to apply.",
		vim.log.levels.INFO,
		{ title = TITLE }
	)
end

function M.edit_local_properties()
	if not local_properties.exists() then
		if not M.write_local_properties({
			ai = {
				provider = M.get_runtime_provider(),
			},
		}) then
			return
		end
	end

	vim.cmd("edit " .. vim.fn.fnameescape(local_properties.path()))
end

function M.show_status()
	local runtime_provider = M.get_runtime_provider()
	local configured_provider = M.get_configured_provider()

	vim.notify(
		table.concat({
			"Current session: " .. M.get_provider_label(runtime_provider),
			"Next start: " .. M.get_provider_label(configured_provider),
			"Local override: " .. (local_properties.exists() and local_properties.path() or "not created"),
		}, "\n"),
		vim.log.levels.INFO,
		{ title = TITLE }
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
