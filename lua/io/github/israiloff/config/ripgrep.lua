local log_status, log = pcall(require, "io.github.israiloff.config.logger")

if not log_status then
    print("Error: 'io.github.israiloff.config.logger' not found. ripgrep will not be installed.")
    return
end

local logger_name = "io.github.israiloff.config.ripgrep"

-- `vim.fn.executable` is a PATH lookup; the previous `io.popen("command -v rg")`
-- spawned a shell synchronously on every single startup (and never worked on
-- Windows, where `command -v` does not exist).
if vim.fn.executable("rg") == 1 then
    return
end

if vim.fn.executable("cargo") ~= 1 then
    log.warn(logger_name, "ripgrep not found and cargo is unavailable; install ripgrep manually for Telescope grep.")
    return
end

log.info(logger_name, "ripgrep not found, installing via cargo...")

local uv = vim.uv or vim.loop

uv.spawn("cargo", {
    args = { "install", "ripgrep" },
}, function(code, _)
    vim.schedule(function()
        if code ~= 0 then
            log.error(logger_name, "Failed to install ripgrep. Exit code: " .. code)
            return
        end

        log.info(logger_name, "ripgrep has been successfully installed.")

        local home = os.getenv("HOME")
        if not home then
            return
        end

        local cargo_bin = home .. "/.cargo/bin"

        if not string.find(vim.env.PATH or "", cargo_bin, 1, true) then
            vim.env.PATH = (vim.env.PATH or "") .. ":" .. cargo_bin
            log.info(logger_name, cargo_bin .. " has been added to PATH.")
        end
    end)
end)
