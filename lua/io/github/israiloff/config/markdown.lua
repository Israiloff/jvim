vim.g.mkdp_open_to_the_world = 1
vim.g.mkdp_open_ip = "127.0.0.1"
vim.g.mkdp_port = 33235
vim.g.mkdp_browser = "none"
vim.g.mkdp_echo_preview_url = 1
vim.g.mkdp_auto_start = 1

-- Keep a preview open after you leave its buffer.
--
-- The plugin defaults this to 1, which hangs a `BufHidden` autocmd on every
-- previewed buffer and closes its page the moment you switch away. Two markdown
-- files open meant one live preview and one dead tab — not a rendering limit,
-- this setting.
--
-- Pages are not closed for you now, so they stay until you close them or run
-- `:MarkdownPreviewStop`. With `mkdp_browser = "none"` they are opened by hand
-- anyway, so it is the same hand that closes them.
vim.g.mkdp_auto_close = 0
