local shell = require("io.github.israiloff.config.shell").get_shell()
require("toggleterm").setup({
    size = function(term)
        if term.direction == "horizontal" then
            return 15
        elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
        end
    end,
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
    persist_size = true,
    direction = "float",
    close_on_exit = true,
    shell = shell,
    float_opts = {
        border = "single",
        winblend = 0,
    },
})

local function create_terminal(direction)
    return require("toggleterm.terminal").Terminal:new({
        direction = direction,
        hidden = true,
        highlights = {
            border = {
                "FloatBorder",
                "Normal",
            },
        },
    })
end

-- Create the terminal instances once and reuse them
local float_term = create_terminal("float")
local vertical_term = create_terminal("vertical")
local horizontal_term = create_terminal("horizontal")

-- Functions to toggle the terminals
function _G.toggle_float_term()
    float_term:toggle()
end

function _G.toggle_vertical_term()
    vertical_term:toggle()
end

function _G.toggle_horizontal_term()
    horizontal_term:toggle()
end

function _G.exec_in_terminal_horizontal(cmd)
    horizontal_term:toggle().send(horizontal_term, cmd)
end

-- Keymaps to toggle terminals with specific directions (Normal mode)
vim.api.nvim_set_keymap(
    "n",
    "<M-3>",
    ":lua toggle_float_term()<CR>",
    { noremap = true, silent = true, desc = "Toggle floating terminal" }
)
vim.api.nvim_set_keymap(
    "n",
    "<M-2>",
    ":lua toggle_vertical_term()<CR>",
    { noremap = true, silent = true, desc = "Toggle vertical terminal" }
)
vim.api.nvim_set_keymap(
    "n",
    "<M-1>",
    ":lua toggle_horizontal_term()<CR>",
    { noremap = true, silent = true, desc = "Toggle horizontal terminal" }
)

-- Terminal mode keymaps to toggle terminals (Terminal mode)
vim.api.nvim_set_keymap(
    "t",
    "<M-3>",
    [[<C-\><C-n>:lua toggle_float_term()<CR>]],
    { noremap = true, silent = true, desc = "Toggle floating terminal" }
)
vim.api.nvim_set_keymap(
    "t",
    "<M-2>",
    [[<C-\><C-n>:lua toggle_vertical_term()<CR>]],
    { noremap = true, silent = true, desc = "Toggle vertical terminal" }
)
vim.api.nvim_set_keymap(
    "t",
    "<M-1>",
    [[<C-\><C-n>:lua toggle_horizontal_term()<CR>]],
    { noremap = true, silent = true, desc = "Toggle horizontal terminal" }
)

-- Keymaps to toggle terminals with specific directions (Normal mode) for MAC OS
vim.api.nvim_set_keymap(
    "n",
    "£",
    ":lua toggle_float_term()<CR>",
    { noremap = true, silent = true, desc = "Toggle floating terminal" }
)

vim.api.nvim_set_keymap(
    "n",
    "™",
    ":lua toggle_vertical_term()<CR>",
    { noremap = true, silent = true, desc = "Toggle vertical terminal" }
)
vim.api.nvim_set_keymap(
    "n",
    "¡",
    ":lua toggle_horizontal_term()<CR>",
    { noremap = true, silent = true, desc = "Toggle horizontal terminal" }
)

-- Terminal mode keymaps to toggle terminals (Terminal mode) for MAC OS
vim.api.nvim_set_keymap(
    "t",
    "£",
    [[<C-\><C-n>:lua toggle_float_term()<CR>]],
    { noremap = true, silent = true, desc = "Toggle floating terminal" }
)
vim.api.nvim_set_keymap(
    "t",
    "™",
    [[<C-\><C-n>:lua toggle_vertical_term()<CR>]],
    { noremap = true, silent = true, desc = "Toggle vertical terminal" }
)
vim.api.nvim_set_keymap(
    "t",
    "¡",
    [[<C-\><C-n>:lua toggle_horizontal_term()<CR>]],
    { noremap = true, silent = true, desc = "Toggle horizontal terminal" }
)
