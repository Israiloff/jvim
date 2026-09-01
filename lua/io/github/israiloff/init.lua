-- Startup path.
--
-- Only things that must exist before any plugin loads live here. Everything that
-- configures a plugin now lives in that plugin's lazy.nvim spec
-- (`config/plugins.lua`), so the plugin's own `event`/`ft`/`cmd`/`keys` trigger
-- decides when it — and its config — is loaded.

-- Editor-level settings (no plugin dependency).
require("io.github.israiloff.config.startup")
require("io.github.israiloff.config.editor")
require("io.github.israiloff.config.formatting")
require("io.github.israiloff.config.diagnostics")
require("io.github.israiloff.config.clipboard")

-- User commands and keymaps that must be available immediately. Both only
-- reference plugins through `<Cmd>...` strings, so they do not force a load.
require("io.github.israiloff.config.buffer-ops")
require("io.github.israiloff.config.keymap")

-- Activity indicator. Must be registered before lazy.nvim so that it sees the
-- `User LazyLoad` events, and it deliberately depends on no plugin.
require("io.github.israiloff.config.activity").setup()

-- Plugin manager. Everything else is pulled in from here on demand.
require("io.github.israiloff.config.lazy")

-- Deferred housekeeping: checking for ripgrep should never block the first paint.
-- "VeryLazy" is a User event emitted by lazy.nvim once the UI has settled.
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	once = true,
	callback = function()
		require("io.github.israiloff.config.ripgrep")
		-- Registers `:JvimResources`, and puts the panel back on screen when
		-- it was left on. Nothing is polled while it is off.
		require("io.github.israiloff.config.resources").setup()
	end,
})
