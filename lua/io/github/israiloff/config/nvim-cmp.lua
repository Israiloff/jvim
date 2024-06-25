local cmp = require("cmp")
local luasnip = require("luasnip")
local cmp_mapping = require("cmp.config.mapping")
local cmp_types = require("cmp.types.cmp")

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-k>"] = cmp_mapping(cmp_mapping.select_prev_item(), { "i", "c" }),
		["<C-j>"] = cmp_mapping(cmp_mapping.select_next_item(), { "i", "c" }),
		["<Down>"] = cmp_mapping(cmp_mapping.select_next_item({ behavior = cmp_types.SelectBehavior.Select }), { "i" }),
		["<Up>"] = cmp_mapping(cmp_mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Select }), { "i" }),
		["<C-d>"] = cmp_mapping.scroll_docs(-4),
		["<C-f>"] = cmp_mapping.scroll_docs(4),
		["<C-y>"] = cmp_mapping({
			i = cmp_mapping.confirm({ behavior = cmp_types.ConfirmBehavior.Replace, select = false }),
			c = function(fallback)
				if cmp.visible() then
					cmp.confirm({ behavior = cmp_types.ConfirmBehavior.Replace, select = false })
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
				-- cmp.complete()
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
		["<C-e>"] = cmp_mapping.abort(),
		["<CR>"] = cmp_mapping(function(fallback)
			if cmp.visible() then
				local confirm_opts = vim.deepcopy(lvim.builtin.cmp.confirm_opts) -- avoid mutating the original opts below
				local is_insert_mode = function()
					return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
				end
				if is_insert_mode() then -- prevent overwriting brackets
					confirm_opts.behavior = cmp_types.ConfirmBehavior.Insert
				end
				local entry = cmp.get_selected_entry()
				local is_copilot = entry and entry.source.name == "copilot"
				if is_copilot then
					confirm_opts.behavior = cmp_types.ConfirmBehavior.Replace
					confirm_opts.select = true
				end
				if cmp.confirm(confirm_opts) then
					return -- success, exit early
				end
			end
			fallback() -- if not exited early, always fallback
		end),
	}),
	sources = cmp.config.sources({
		{
			name = "copilot",
			max_item_count = 3,
			trigger_characters = {
				{
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
	}),
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
