-- Spring Boot support toggle.
--
-- Spring Boot tooling is *not* a replacement for jdtls — it is an add-on that
-- runs on top of it:
--
--   * `spring-boot-language-server` starts as a second LSP client (name
--     "spring-boot") on java / application.yml / application.properties buffers;
--   * a set of JDT extension jars is handed to jdtls through
--     `init_options.bundles`, and the boot server reaches back into jdtls over
--     `workspace/executeCommand` for the type model.
--
-- That second server is a full extra JVM (the plugin hardcodes `-Xmx1G`), so the
-- whole thing is opt-in and defaults to off.
--
-- Because the bundles are only read by jdtls at client start, flipping the
-- toggle cannot take effect in the running session; the choice is persisted to
-- `properties-local.lua` and applied on the next start, exactly like the AI
-- provider switch in `config/ai.lua`.

local M = {}

local properties = require("io.github.israiloff.config.properties")
local local_properties = require("io.github.israiloff.config.local-properties")
local logger = require("io.github.israiloff.config.logger")

local TITLE = "JVIM Spring"
local logger_name = "io.github.israiloff.config.java.spring"

-- The mason package that ships both halves: the language server jar and the
-- jdtls extension jars.
M.mason_package = "vscode-spring-boot-tools"

-- Name the boot server registers itself under. Used to keep buffer-scoped
-- features that assume a single Java server from binding to it.
M.client_name = "spring-boot"

local function normalize(value)
	return value == true
end

-- Whether Spring Boot support is live in *this* session. Properties are frozen
-- at startup, so this never changes while Neovim runs.
function M.is_enabled()
	return normalize(properties.spring and properties.spring.enabled)
end

-- Whether it will be on after the next start. Differs from `is_enabled` between
-- a toggle and the restart that applies it.
function M.get_configured()
	local spring = local_properties.read(TITLE).spring

	if type(spring) ~= "table" or spring.enabled == nil then
		return M.is_enabled()
	end

	return normalize(spring.enabled)
end

function M.get_label(enabled)
	return enabled and "On" or "Off"
end

function M.set_enabled(enabled)
	enabled = normalize(enabled)

	if not local_properties.set({ "spring", "enabled" }, enabled, TITLE) then
		return
	end

	vim.notify(
		"Spring Boot support for the next Neovim start: " .. M.get_label(enabled) .. ". Restart Neovim to apply.",
		vim.log.levels.INFO,
		{ title = TITLE }
	)

	if enabled and not M.is_installed() then
		vim.notify(
			"Run `:MasonInstall " .. M.mason_package .. "` before restarting — the server is not installed yet.",
			vim.log.levels.WARN,
			{ title = TITLE }
		)
	end
end

function M.toggle()
	M.set_enabled(not M.get_configured())
end

function M.is_installed()
	local ok, mason_registry = pcall(require, "mason-registry")
	if not ok then
		return false
	end

	local has_package, package = pcall(mason_registry.get_package, M.mason_package)
	if not has_package then
		return false
	end

	local installed_ok, installed = pcall(function()
		return package:is_installed()
	end)

	return installed_ok and installed
end

-- jdtls bundles contributed by the Spring Boot tooling, for
-- `init_options.bundles`. Empty when the feature is off or the plugin/mason
-- package is missing, so the caller can splice the result in unconditionally.
function M.java_extensions()
	if not M.is_enabled() then
		return {}
	end

	local ok, spring_boot = pcall(require, "spring_boot")
	if not ok then
		return {}
	end

	local jars_ok, jars = pcall(spring_boot.java_extensions)
	if not jars_ok or type(jars) ~= "table" then
		return {}
	end

	return jars
end

-- Java highlighting is owned by treesitter and the colorscheme, which is why
-- `ftplugin/java.lua` drops jdtls's semantic tokens. The boot server advertises
-- them as well, and semantic tokens outrank treesitter (priority 125 against
-- 100), so whatever it reports repaints keywords like `private` and `final`
-- with `@lsp.type.*` groups the colorscheme does not style — they come out the
-- colour of plain text. Drop them here for the same reason.
function M.on_attach(client, bufnr)
	client.server_capabilities.semanticTokensProvider = nil
	pcall(vim.lsp.semantic_tokens.stop, bufnr, client.id)
end

-- LSP MessageType (1 Error … 5 Debug) mapped onto the project logger.
local message_levels = {
	[1] = logger.error,
	[2] = logger.warn,
	[3] = logger.info,
	[4] = logger.debug,
	[5] = logger.debug,
}

-- The boot server talks about itself on every start ("Embedded Spring Tools MCP
-- server started at port: ..."), and Neovim's default `window/showMessage`
-- handler echoes that straight into `:messages`. Send the server's own chatter
-- to the project logger instead, so `properties.logger.enabled` decides whether
-- anyone sees it. `window/logMessage` is deliberately left alone: it already
-- goes to the LSP log file without interrupting anything.
local function log_server_message(_, result)
	if type(result) ~= "table" or not result.message then
		return result
	end

	local log = message_levels[result.type] or logger.info
	log(logger_name, result.message)

	return result
end

-- Options handed to `spring_boot.setup()`. The plugin would otherwise resolve
-- java from `$JAVA_HOME` or `$PATH` on its own; routing it through the same
-- helper jdtls uses keeps both servers on one JDK.
--
-- `server` is merged over the plugin's own client config with "keep", so only
-- the keys named here override it — the plugin's own `sts/*` handlers survive.
function M.ls_opts()
	local utils_ok, utils = pcall(require, "io.github.israiloff.config.utils")

	return {
		java_cmd = utils_ok and utils.get_java_path() or nil,
		server = {
			on_attach = M.on_attach,
			handlers = {
				["window/showMessage"] = log_server_message,
			},
		},
	}
end

-- Filetypes the boot server attaches to, mirroring `spring_boot.ls_config`.
local target_filetypes = {
	java = true,
	yaml = true,
	jproperties = true,
}

local augroup = "spring_boot_ls"

-- `spring_boot.setup()` starts the server from a FileType autocmd it registers
-- itself — but by the time it runs, FileType has already fired for the buffer
-- that pulled the plugin in: `ftplugin/java.lua` requires this module mid-event
-- to collect the jdtls bundles. Without a replay the first Java buffer of the
-- session never gets the server, only the second one onwards.
--
-- The replay is scheduled rather than immediate so it lands after
-- `jdtls.start_or_attach`; the boot server queries jdtls for the project
-- classpath and finds nothing if it wins the race.
local function replay_filetype(bufnr)
	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end

		local filetype = vim.bo[bufnr].filetype
		if not target_filetypes[filetype] then
			return
		end

		vim.api.nvim_buf_call(bufnr, function()
			pcall(vim.api.nvim_exec_autocmds, "FileType", {
				group = augroup,
				pattern = filetype,
				modeline = false,
			})
		end)
	end)
end

function M.setup()
	local ok, spring_boot = pcall(require, "spring_boot")
	if not ok then
		vim.notify("spring-boot.nvim not found.", vim.log.levels.ERROR, { title = TITLE })
		return
	end

	spring_boot.setup(M.ls_opts())
	replay_filetype(vim.api.nvim_get_current_buf())
end

function M.show_status()
	local runtime = M.is_enabled()
	local configured = M.get_configured()

	vim.notify(
		table.concat({
			"Current session: " .. M.get_label(runtime),
			"Next start: " .. M.get_label(configured),
			"Server package: " .. M.mason_package .. " (" .. (M.is_installed() and "installed" or "missing") .. ")",
			"Local override: " .. (local_properties.exists() and local_properties.path() or "not created"),
		}, "\n"),
		vim.log.levels.INFO,
		{ title = TITLE }
	)
end

if vim.fn.exists(":JvimSpringToggle") == 0 then
	vim.api.nvim_create_user_command("JvimSpringToggle", function()
		M.toggle()
	end, {
		desc = "Toggle Spring Boot support for the next Neovim start",
	})
end

if vim.fn.exists(":JvimSpringEnable") == 0 then
	vim.api.nvim_create_user_command("JvimSpringEnable", function()
		M.set_enabled(true)
	end, {
		desc = "Enable Spring Boot support for the next Neovim start",
	})
end

if vim.fn.exists(":JvimSpringDisable") == 0 then
	vim.api.nvim_create_user_command("JvimSpringDisable", function()
		M.set_enabled(false)
	end, {
		desc = "Disable Spring Boot support for the next Neovim start",
	})
end

if vim.fn.exists(":JvimSpringStatus") == 0 then
	vim.api.nvim_create_user_command("JvimSpringStatus", function()
		M.show_status()
	end, {
		desc = "Show active and configured Spring Boot support",
	})
end

return M
