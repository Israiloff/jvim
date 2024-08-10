local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
    print("Error: 'io.github.israiloff.config.logger' not found. Telescope Live Grep Args will not be configured.")
    return
end

local logger_name = "io.github.israiloff.config.telescope-live-grep-args"

-- Check if ripgrep is installed
local handle = io.popen("command -v rg")

if not handle then
    log.error(logger_name, "Failed to check if ripgrep is installed.")
    return
end

local result = handle:read("*a")
handle:close()

if result == "" then
    log.info(logger_name, "ripgrep not found, installing via cargo...")

    -- Run the installation command asynchronously
    vim.uv.spawn("cargo", {
        args = { "install", "ripgrep" },
    }, function(code, _)
        vim.schedule(function()
            if code == 0 then
                log.info(logger_name, "ripgrep has been successfully installed.")

                local cargo_bin = os.getenv("HOME") .. "/.cargo/bin"
                local path = os.getenv("PATH")

                if not path then
                    log.error(logger_name, "Failed to get PATH.")
                    return
                end

                if not string.find(path, cargo_bin, 1, true) then
                    vim.env.PATH = vim.env.PATH .. ":" .. cargo_bin
                    log.info(logger_name, cargo_bin .. " has been added to PATH.")
                end
            else
                log.error(logger_name, "Failed to install ripgrep. Exit code: " .. code)
            end
        end)
    end)
end
