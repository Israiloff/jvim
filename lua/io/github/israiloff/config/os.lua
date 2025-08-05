OS = {
    WINDOWS = "win",
    LINUX = "linux",
    MAC = "mac",
}

function OS.get_current_os()
    local os_real_name = vim.fn.expand("$OS")

    if string.match(os_real_name, "[Mm][Aa][Cc]") then
        return OS.MAC
    elseif string.match(os_real_name, "[Ww][Ii][Nn]") then
        return OS.WINDOWS
    elseif string.match(os_real_name, "[Ll][Ii][Nn][Uu][Xx]") then
        return OS.LINUX
    else
        return nil
    end
end

return OS
