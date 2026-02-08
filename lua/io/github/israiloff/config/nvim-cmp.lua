_G.cmp = require("cmp")
local luasnip = require("luasnip")
local cmp_mapping = require("cmp.config.mapping")
local cmp_types = require("cmp.types.cmp")
local ConfirmBehavior = cmp_types.ConfirmBehavior
local SelectBehavior = cmp_types.SelectBehavior
local lspkind = require("lspkind")

local function has_words_before()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local function jumpable(dir)
	local win_get_cursor = vim.api.nvim_win_get_cursor
	local get_current_buf = vim.api.nvim_get_current_buf

	local function seek_luasnip_cursor_node()
		if not luasnip.session.current_nodes then
			return false
		end

		local node = luasnip.session.current_nodes[get_current_buf()]
		if not node then
			return false
		end

		local snippet = node.parent.snippet
		local exit_node = snippet.insert_nodes[0]

		local pos = win_get_cursor(0)
		pos[1] = pos[1] - 1

		if exit_node then
			local exit_pos_end = exit_node.mark:pos_end()
			if (pos[1] > exit_pos_end[1]) or (pos[1] == exit_pos_end[1] and pos[2] > exit_pos_end[2]) then
				snippet:remove_from_jumplist()
				luasnip.session.current_nodes[get_current_buf()] = nil

				return false
			end
		end

		node = snippet.inner_first:jump_into(1, true)
		while node ~= nil and node.next ~= nil and node ~= snippet do
			local n_next = node.next
			local next_pos = n_next and n_next.mark:pos_begin()
			local candidate = n_next ~= snippet and next_pos and (pos[1] < next_pos[1])
				or (pos[1] == next_pos[1] and pos[2] < next_pos[2])

			if n_next == nil or n_next == snippet.next then
				snippet:remove_from_jumplist()
				luasnip.session.current_nodes[get_current_buf()] = nil
				return false
			end

			if candidate then
				luasnip.session.current_nodes[get_current_buf()] = node
				return true
			end

			local ok
			ok, node = pcall(node.jump_from, node, 1, true)
			if not ok then
				snippet:remove_from_jumplist()
				luasnip.session.current_nodes[get_current_buf()] = nil

				return false
			end
		end

		if exit_node then
			luasnip.session.current_nodes[get_current_buf()] = snippet
			return true
		end

		snippet:remove_from_jumplist()
		luasnip.session.current_nodes[get_current_buf()] = nil
		return false
	end

	if dir == -1 then
		return luasnip.in_snippet() and luasnip.jumpable(-1)
	else
		return luasnip.in_snippet() and seek_luasnip_cursor_node() and luasnip.jumpable(1)
	end
end

cmp.setup({
	confirm_opts = {
		behavior = ConfirmBehavior.Replace,
		select = false,
	},
	completion = {
		keyword_length = 1,
	},
	experimental = {
		ghost_text = false,
		native_menu = false,
	},
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol",
			maxwidth = {
				menu = 50,
				abbr = 50,
			},
			ellipsis_char = "...",
			show_labelDetails = true,
		}),
		fields = { "icon", "abbr", "menu" },
		expandable_indicator = true,
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	window = {
		completion = cmp.config.window.bordered({
			border = "single",
		}),
		documentation = cmp.config.window.bordered({
			border = "single",
		}),
	},
	sources = {
		{
			name = "copilot",
			max_item_count = 3,
			trigger_characters = {
				".",
				":",
				"(",
				"'",
				'"',
				"[",
				",",
				"#",
				"*",
				"@",
				"|",
				"=",
				"-",
				"{",
				"/",
				"\\",
				"+",
				"?",
				" ",
			},
		},
		{
			name = "nvim_lsp",
			entry_filter = function(entry, ctx)
				local kind = require("cmp.types.lsp").CompletionItemKind[entry:get_kind()]
				if kind == "Snippet" and ctx.prev_context.filetype == "java" then
					return false
				end
				return true
			end,
		},

		{ name = "path" },
		{ name = "luasnip" },
		{ name = "cmp_tabnine" },
		{ name = "nvim_lua" },
		{ name = "buffer" },
		{ name = "calc" },
		{ name = "emoji" },
		{ name = "treesitter" },
		{ name = "crates" },
		{ name = "tmux" },
	},
	mapping = cmp_mapping.preset.insert({
		["<C-k>"] = cmp_mapping(cmp_mapping.select_prev_item(), { "i", "c" }),
		["<C-j>"] = cmp_mapping(cmp_mapping.select_next_item(), { "i", "c" }),
		["<Down>"] = cmp_mapping(cmp_mapping.select_next_item({ behavior = SelectBehavior.Select }), { "i" }),
		["<Up>"] = cmp_mapping(cmp_mapping.select_prev_item({ behavior = SelectBehavior.Select }), { "i" }),
		["<C-d>"] = cmp_mapping.scroll_docs(-4),
		["<C-f>"] = cmp_mapping.scroll_docs(4),
		["<C-y>"] = cmp_mapping({
			i = cmp_mapping.confirm({ behavior = ConfirmBehavior.Replace, select = false }),
			c = function(fallback)
				if cmp.visible() then
					cmp.confirm({ behavior = ConfirmBehavior.Replace, select = false })
				else
					fallback()
				end
			end,
		}),
		["<Tab>"] = cmp_mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			elseif jumpable(1) then
				luasnip.jump(1)
			elseif has_words_before() then
				fallback()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp_mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-Space>"] = cmp_mapping.complete(),
		["<M-Space>"] = cmp_mapping.complete(),
		["<D-L>"] = cmp_mapping.complete(), -- Option + Space
		["<C-e>"] = cmp_mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	cmdline = {
		enable = false,
		options = {
			{
				type = ":",
				sources = {
					{ name = "path" },
					{ name = "cmdline" },
				},
			},
			{
				type = { "/", "?" },
				sources = {
					{ name = "buffer" },
				},
			},
		},
	},
})

cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})
