return {
	version = "0.15.28",
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
	gui = {
		transparent = true,
	},
    shell = {
        WINDOWS = "pwsh.exe",
        LINUX = "zsh",
        MACOS = "zsh"
    }
}
