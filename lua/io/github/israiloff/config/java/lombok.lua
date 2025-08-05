M = {}

M.lombok_path = vim.fn.stdpath("data") .. "/lombok.jar"

local lombok_url = "https://projectlombok.org/downloads/lombok.jar"
local utils = require("io.github.israiloff.config.utils")

function M.setup()
	utils.download_if_missing(M.lombok_path, lombok_url)
end

return M
