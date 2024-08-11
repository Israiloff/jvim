M = {}

local logger = require("io.github.israiloff.config.logger")
local logger_name = "io.github.israiloff.config.utils"
local curl_status, curl = pcall(require, "plenary.curl")

local function file_exists(path)
    logger.debug(logger_name, "Checking if file exists: " .. path)
    return vim.fn.filereadable(path) == 1
end

local function download(url, path)
    logger.debug(logger_name, "Downloading " .. url .. " to " .. path)
    if not curl_status then
        logger.error(logger_name, "plenary.curl not found, please install it and try again")
        return
    end
    local response = curl.get(url, { output = path })
    if response.status == 200 then
        logger.debug(logger_name, "Downloaded file '" .. path .. "' from " .. url)
    else
        logger.error(logger_name, "Failed to download file '" .. path .. "' from " .. url)
    end
end

function M.download_if_missing(file_path, file_url)
    logger.debug(logger_name, "Downloading if missing file " .. file_path .. " from " .. file_url)
    if not file_exists(file_path) then
        download(file_url, file_path)
    end
    logger.debug(logger_name, "Downloaded: " .. file_path)
    return file_path
end

function M.create_dirs(path)
    logger.debug(logger_name, "Creating directories: " .. path)
    vim.fn.mkdir(path, "p")
end

function M.isempty(s)
    logger.debug(logger_name, "Checking if string is empty")
    return s == nil or s == ""
end

function M.get_java_path()
    local java_home = vim.fn.getenv("JAVA_HOME")
    if java_home ~= vim.NIL and java_home ~= "" then
        return java_home .. "/bin/java"
    end

    local common_paths = {
        "/usr/bin/java",
        "/usr/local/bin/java",
        "/opt/java/bin/java",
    }
    for _, path in ipairs(common_paths) do
        if vim.fn.filereadable(path) == 1 then
            return path
        end
    end

    logger.error(logger_name, "Java not found in JAVA_HOME or PATH")
end

function M.get_ftplugin_filetypes()
    local ftplugin_filetypes = {}
    local ftplugin_dir = vim.fn.stdpath("config") .. "/ftplugin"
    local ftplugin_files = vim.fn.glob(ftplugin_dir .. "/*.lua", false, true)
    for _, file in ipairs(ftplugin_files) do
        local filetype = vim.fn.fnamemodify(file, ":t:r")
        table.insert(ftplugin_filetypes, filetype)
    end
    return ftplugin_filetypes
end

return M
