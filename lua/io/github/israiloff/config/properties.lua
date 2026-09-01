local function load_local_properties()
	local local_properties_path = vim.fn.stdpath("config") .. "/lua/io/github/israiloff/config/properties-local.lua"
	local uv = vim.uv or vim.loop

	if not uv.fs_stat(local_properties_path) then
		return {}
	end

	local chunk, load_err = loadfile(local_properties_path)
	if not chunk then
		vim.notify("Failed to load local properties: " .. load_err, vim.log.levels.ERROR)
		return {}
	end

	local ok, local_properties = pcall(chunk)
	if not ok then
		vim.notify("Failed to evaluate local properties: " .. local_properties, vim.log.levels.ERROR)
		return {}
	end

	if type(local_properties) ~= "table" then
		vim.notify("Local properties must return a table: " .. local_properties_path, vim.log.levels.ERROR)
		return {}
	end

	return local_properties
end

local base_properties = {
	-- Version of the JVIM IDE.
	version = "0.45.2",
	-- Logging configuration.
	--
	-- On by default, but at error level only: a failure inside the config used to
	-- be swallowed entirely unless you knew to turn logging on first. The quieter
	-- levels stay off — they are for tracing startup, not for daily use — and all
	-- of them are switchable from the Notifications menu.
	logger = {
		enabled = true,
		level = {
			debug = false,
			info = false,
			warn = false,
			error = true,
		},
		enabled_loggers = { "*" },
	},
	-- The default configuration for graphical user interface.
	-- This is used to determine the appearance of the GUI.
	gui = {
		transparent = true,
		-- Bottom-right activity panel.
		-- Reports lazy.nvim plugin loads, LSP progress (jdtls indexing in
		-- particular, which is otherwise completely silent) and notifications.
		activity = {
			enabled = true,
			lazy = true,
			lsp = true,
			-- How long an in-flight LSP task may stay silent before the panel
			-- gives up on it. Servers do abandon progress tokens without ever
			-- closing them; jdtls does it whenever an internal job dies or
			-- blocks. Reports are throttled to a few hundred milliseconds, so
			-- a minute of silence means stuck, not slow.
			lsp_stale_ms = 60000,
			-- Route `vim.notify` — the project logger included — into the panel
			-- instead of the message area. `:messages` still records everything.
			notify = true,
			linger_ms = 1200,
			-- Per-level dwell time for notifications; errors get longer.
			notify_linger_ms = {
				error = 8000,
				warn = 6000,
				info = 4000,
				debug = 3000,
			},
			notify_max_lines = 6,
			interval_ms = 80,
			max_width = 60,
			max_entries = 6,
		},
		-- Resource monitor (`:JvimResources`). Samples the processes Neovim
		-- runs — the language server JVMs above all — so that growth that
		-- never comes back down is visible.
		resources = {
			-- Whether the panel is on screen. Saved, so a session that wants
			-- to watch its servers keeps watching them across restarts; the
			-- switch is in the UI menu and nothing is polled while it is off.
			enabled = false,
			interval_ms = 2000,
			max_entries = 8,
			history = 12,
			max_width = 64,
			-- Growth over the first sample, in megabytes, before a row is
			-- called out.
			growth_warning_mb = 256,
		},
	},
	-- The default shell to use for the system.
	-- This is used to determine the preferred shell for the system.
	-- It is set to "pwsh.exe" for Windows, "zsh" for Linux and macOS.
	-- It can be overridden by setting the environment variables.
	shell = {
		WINDOWS = "pwsh.exe",
		LINUX = "zsh",
		MACOS = "zsh",
	},
	-- AI provider configuration.
	-- provider: "copilot" | "tabby" | "none"
	ai = {
		provider = "copilot",
		tabby = {
			agent_start_command = { "npx", "tabby-agent", "--stdio" },
			inline_completion_trigger = "auto",
		},
	},
	-- Spring Boot support (spring-boot.nvim + spring-boot-language-server).
	-- Layers on top of jdtls rather than replacing it: adds content-assist for
	-- Spring Data repository query methods, application.yml/.properties
	-- completion, bean and endpoint navigation.
	-- Costs a second LSP client and a second JVM, so it is off by default.
	-- Toggle with `:JvimSpringToggle`; takes effect on the next start.
	spring = {
		enabled = false,
	},
	-- The default configuration for the Java Development Tools Language Server (JDTLS).
	-- This is used to determine the JVM options for the JDTLS.
	-- It is set to a minimum heap size of 256M and a maximum heap size of 1G.
	-- It can be overridden by setting the environment variables or by modifying this configuration.
	jdtls = {
		jvm = {
			xms = "256M",
			xmx = "1G",
		},
	},
}

return vim.tbl_deep_extend("force", base_properties, load_local_properties())
