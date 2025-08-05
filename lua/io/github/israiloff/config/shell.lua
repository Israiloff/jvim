SHELL = {}

function SHELL.get_shell()
    local shell = require("io.github.israiloff.config.properties").shell
    local os = require("io.github.israiloff.config.os")
    local current_os = os.get_current_os()
    if current_os == os.LINUX then
        return shell.LINUX
    elseif current_os == os.MACOS then
        return shell.MACOS
    elseif current_os == os.WINDOWS then
        return shell.WINDOWS
    else
        return vim.o.shell
    end
end

return SHELL
