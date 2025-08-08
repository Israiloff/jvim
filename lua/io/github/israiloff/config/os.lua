local logger_status, logger = pcall(require, "io.github.israiloff.config.logger")

if not logger_status then
    print("JAVA: io.github.israiloff.config.logger not found, please install it and try again")
    return
end

local logger_name = "io.github.israiloff.config.os"

OS = {
    WINDOWS = "win",
    LINUX = "linux",
    MAC = "mac",
}

function OS.get_current_os()
    logger.debug(logger_name, "OS: determining current operating system...")

    local os_real_name = vim.fn.expand("$OS")

    logger.debug(logger_name, "OS: real name is '" .. os_real_name .. "'")

    if string.match(os_real_name, "[Mm][Aa][Cc]") then
        logger.debug(logger_name, "OS: detected macOS")
        return OS.MAC
    elseif string.match(os_real_name, "[Ww][Ii][Nn]") then
        logger.debug(logger_name, "OS: detected Windows")
        return OS.WINDOWS
    elseif string.match(os_real_name, "[Ll][Ii][Nn][Uu][Xx]") then
        logger.debug(logger_name, "OS: detected Linux")
        return OS.LINUX
    else
        logger.error(logger_name, "OS: unknown operating system '" .. os_real_name .. "'")
        return nil
    end
end

return OS
