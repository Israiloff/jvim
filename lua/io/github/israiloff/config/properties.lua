return {
    -- Version of the JVIM IDE.
    version = "0.22.41",
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
    -- Architecture of the system.
    -- This is used to determine the correct binary to use for the system.
    -- It is set to "x86_64" by default, but can be overridden
    -- by setting the environment variable "ARCHITECTURE" to "arm" for ARM architectures.
    architecture = "x86_64",
}
