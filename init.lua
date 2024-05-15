-- map leader to <Space>
vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			local telescope = require('telescope')
			local actions = require('telescope.actions')
			telescope.setup {
				pickers = {
					find_files = {
						hidden = true
					}
				},
				extensions = {
					live_grep_args = {
						mappings = {
							i = {
								['<C-n>'] = actions.cycle_history_next,
								['<C-p>'] = actions.cycle_history_prev,
							},
						},
					},
				},
			}

			local builtin = require('telescope.builtin')
			vim.keymap.set('n', '<leader><leader>', builtin.find_files, {})
			vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
			vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, {})
			vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
			vim.keymap.set('n', '<leader>fb', function() builtin.buffers({ sort_mru = true }) end, {})
			vim.keymap.set('n', '<leader>bb', function() builtin.buffers({ sort_mru = true }) end, {})
			vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
			vim.keymap.set('n', '<leader>f.',
				':Telescope file_browser path=%:p:h select_buffer=true hidden=true<CR>', {})
			vim.keymap.set('n', '<leader>.',
				':Telescope file_browser path=%:p:h select_buffer=true hidden=true<CR>', {})
			vim.keymap.set('n', '<leader>sb', ':Telescope current_buffer_fuzzy_find<CR>', {})
			vim.keymap.set('n', '<leader>ss', ':Telescope current_buffer_fuzzy_find<CR>', {})
			vim.keymap.set('n', '<leader>fbd',
				function() builtin.find_files({ cwd = require('telescope.utils').buffer_dir() }) end,
				{})
		end
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim"
		},
		config = function()
			require("telescope").load_extension('file_browser')
		end
	},
	{
		'nvim-telescope/telescope-live-grep-args.nvim',
		version = "^1.0.0",
		dependencies = {
			'nvim-telescope/telescope.nvim',
		},
		config = function()
			require("telescope").load_extension("live_grep_args")
			vim.keymap.set('n', '<leader>fG',
				function() require("telescope").extensions.live_grep_args.live_grep_args() end, {})
		end
	},
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'neovim/nvim-lspconfig',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
			'hrsh7th/cmp-vsnip',
			'hrsh7th/vim-vsnip',
		},
		config = function()
			local cmp = require('cmp')
			cmp.setup({
				view = {
					entries = "custom" -- can be "custom", "wildmenu" or "native"
				},
				snippet = {
					-- REQUIRED - you must specify a snippet engine
					expand = function(args)
						vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
						-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
						-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
						-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
					end,
				},
				window = {
					-- completion = cmp.config.window.bordered(),
					-- documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping({
						i = function(fallback)
							if cmp.visible() and cmp.get_active_entry() then
								cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
							else
								fallback()
							end
						end,
						s = cmp.mapping.confirm({ select = true }),
						c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
					}),
				}),
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					-- { name = 'vsnip' }, -- For vsnip users.
					-- { name = 'luasnip' }, -- For luasnip users.
					-- { name = 'ultisnips' }, -- For ultisnips users.
					-- { name = 'snippy' }, -- For snippy users.
				}, {
					{ name = 'buffer' },
				})
			})
			-- Set configuration for specific filetype.
			cmp.setup.filetype('gitcommit', {
				sources = cmp.config.sources({
					{ name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
				}, {
					{ name = 'buffer' },
				})
			})

			-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ '/', '?' }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = 'buffer' }
				}
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = 'path' }
				}, {
					{ name = 'cmdline' }
				})
			})
		end
	},
	'nvim-lua/plenary.nvim',
	'neovim/nvim-lspconfig',
	{
		'stevearc/overseer.nvim',
		config = function()
			require('overseer').setup()
			vim.keymap.set('n', '<leader>pt', function() vim.cmd('OverseerRun') end, {})
		end
	},
	'airblade/vim-gitgutter',
	'tpope/vim-fugitive',
	'raimondi/delimitmate',
})

-- Theme
vim.cmd [[colorscheme eink]]

-- Git
vim.keymap.set('n', '<leader>gg', function() vim.cmd('Git') end, {})

-- Enable line numbers
vim.wo.number = true

-- Don't wrap lines
vim.wo.wrap = false

-- Terminal
vim.keymap.set('t', '<C-space>', '<C-\\><C-n>', {}) -- exit terminal mode

-- window keymap
vim.keymap.set('n', '<leader>wh', '<C-w>h', {})
vim.keymap.set('n', '<leader>wj', '<C-w>j', {})
vim.keymap.set('n', '<leader>wk', '<C-w>k', {})
vim.keymap.set('n', '<leader>wl', '<C-w>l', {})

-- Treesitter
require 'nvim-treesitter.configs'.setup {
	highlight = {
		enable = true,
		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},
}


-- Capabilities for lspconfig.
-- Use default vim.lsp capabilities and apply some tweaks on capabilities.completion for nvim-cmp
local capabilities = vim.tbl_deep_extend("force",
	vim.lsp.protocol.make_client_capabilities(),
	require('cmp_nvim_lsp').default_capabilities()
)
-- Large workspace scanning may freeze the UI; see https://github.com/neovim/neovim/issues/23291
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.pyright.setup {
	capabilities = capabilities
}
lspconfig.clangd.setup {
	capabilities = capabilities
}
-- local is_fuchsia = string.find(vim.loop.cwd() or "", "/fuchsia")
lspconfig.rust_analyzer.setup {
	capabilities = capabilities,
	-- Server-specific settings. See `:help lspconfig-setup`
	settings = {
		['rust-analyzer'] = {
			diagnostics = {
				remapPrefix = {
					["../../"] = "~/fuchsia",
				}
			},
			check = {
				-- overrideCommand = { "fx", "clippy", "--all", "--raw"}
				-- overrideCommand = { "fx", "clippy", "--all", "-f", "$saved_file"}
			}
		},
	},
}
lspconfig.starlark_rust.setup {
	capabilities = capabilities,
}
lspconfig.lua_ls.setup {
	on_init = function(client)
		local path = client.workspace_folders[1].name
		if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
			return
		end

		client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
			runtime = {
				-- Tell the language server which version of Lua you're using
				-- (most likely LuaJIT in the case of Neovim)
				version = 'LuaJIT'
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				-- library = {
				--	vim.env.VIMRUNTIME
				--	-- Depending on the usage, you might want to add additional paths here.
				--	-- "${3rd}/luv/library"
				--	-- "${3rd}/busted/library",
				-- }
				-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
				library = vim.api.nvim_get_runtime_file("", true)
			}
		})
	end,
	settings = {
		Lua = {
			format = {
				enable = true,
				-- Put format options here
				-- NOTE: the value should be STRING!!
				defaultConfig = {
					indent_style = "space",
					indent_size = "2",
				}
			},
		}
	}
}


-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Buffer local mappings.
-- See `:help vim.lsp.*` for documentation on any of the below functions
local opts = {}
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
vim.keymap.set('n', '<leader>bf', function()
	vim.lsp.buf.format { async = true }
end, opts)


-- LSP format on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	callback = function()
		vim.lsp.buf.format()
	end,
})

-- misc keymaps
vim.keymap.set('n', '<leader>bp', '<C-^>', opts)

-- FIDL
vim.filetype.add({ extension = { fidl = "fidl" } })

-- highlight trailing whitespace
vim.opt.listchars = { eol = '↵', trail = '~', tab = '>-', nbsp = '␣' }

vim.cmd [[set notermguicolors]]
vim.cmd [[set bg=light]]
