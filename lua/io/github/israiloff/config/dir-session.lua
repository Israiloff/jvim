-- Layout for `nvim <dir>`.
--
-- Neovim opens a buffer for the directory and nothing renders it, because netrw
-- is disabled in `config/startup.lua`. Letting nvim-tree hijack that buffer does
-- render it, but as a full-window tree with nothing behind it — so toggling the
-- tree off drops you on an empty unnamed buffer.
--
-- The session is therefore composed explicitly: the dashboard takes the main
-- window, the tree opens beside it as a sidebar, and closing the sidebar leaves
-- something usable on screen.
local M = {}

local logger_name = "io.github.israiloff.config.dir-session"

---The directory this session was started on, if it was started on exactly one.
local function directory_argument()
	if vim.fn.argc(-1) ~= 1 then
		return nil
	end

	local path = vim.fn.argv(0)
	local stat = (vim.uv or vim.loop).fs_stat(path)

	if stat and stat.type == "directory" then
		return path
	end

	return nil
end

---Swap the unrendered directory buffer for the dashboard.
local function show_dashboard()
	local directory_buffer = vim.api.nvim_get_current_buf()

	vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(false, true))

	-- Wiped rather than hidden: it is not a real buffer, and leaving it in the
	-- list means `:bnext` and the buffer bar both offer a dead entry.
	if vim.api.nvim_buf_is_valid(directory_buffer) then
		pcall(vim.api.nvim_buf_delete, directory_buffer, { force = true })
	end

	require("lazy").load({ plugins = { "alpha-nvim" } })
	require("alpha").start(false)
end

function M.setup()
	local path = directory_argument()

	if not path then
		return
	end

	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		nested = true,
		callback = function()
			local ok, err = pcall(function()
				show_dashboard()
				-- Requiring the module is what pulls nvim-tree in; it is not
				-- loaded before this point, so its own directory hijack never
				-- gets a chance to claim the window first.
				require("nvim-tree.api").tree.open({ path = path })
			end)

			if not ok then
				require("io.github.israiloff.config.logger").error(
					logger_name,
					"failed to compose the directory session: " .. tostring(err)
				)
			end
		end,
	})
end

return M
