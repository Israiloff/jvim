return {
	-- Version of the JVIM IDE.
	version = "0.30.61",
	-- Logging configuration.
	-- This is used to determine the logging level and whether logging is enabled.
	logger = {
		enabled = false,
		level = {
			debug = true,
			info = true,
			warn = true,
			error = true,
		},
		enabled_loggers = { "*" },
	},
	-- The default configuration for graphical user interface.
	-- This is used to determine the appearance of the GUI.
	gui = {
		transparent = true,
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
