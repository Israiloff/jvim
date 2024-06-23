local icons = require("io.github.israiloff.config.icons")
local which_key = require("which-key") 

which_key.register({
    f = { "<cmd>Telescope find_files<cr>", "Find Files" },
    u = { "<cmd>so<cr>", "Update configs"},
    c = { "<cmd>Ex<cr>", "Close buffer"},
    q = { "<cmd>confirm q<CR>", "Quit"},
}, { prefix = "<leader>", mode = "n" })
