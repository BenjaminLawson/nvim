-- map leader to <Space>
vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
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
				defaults = {
					layout_strategy = "horizontal",
					layout_config = { width = 0.95 },
				},
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
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")

			---@diagnostic disable-next-line: missing-fields
			configs.setup({
				ensure_installed = { "fidl", "cpp", "rust", "markdown", "lua" },
				highlight = {
					enable = true,
					-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
					-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
					-- Using this option may slow down your editor, and you may see some duplicate highlights.
					-- Instead of true it can also be a list of languages
					additional_vim_regex_highlighting = false,
				},
			})
		end
	},
	'nvim-lua/plenary.nvim',
	{
		'williamboman/mason.nvim',
		opts = {
			PATH = "prepend", -- prepend | append | skip
		}
	},
	{
		'stevearc/overseer.nvim',
		config = function()
			require('overseer').setup()
			vim.keymap.set('n', '<leader>pt', function() vim.cmd('OverseerRun') end, {})
		end
	},
	{
		'stevearc/oil.nvim',
		opts = {},
		config = function()
			require("oil").setup({
				skip_confirm_for_simple_edits = true,
				view_options = {
					show_hidden = true,
				}
			})
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
		end
	},
	'airblade/vim-gitgutter',
	'tpope/vim-fugitive',
	{
		'sindrets/diffview.nvim',
		opts = {
			use_icons = false,
			file_panel = {
				listing_style = 'list',
			},
		}
	},
	'raimondi/delimitmate',
	{
		'saghen/blink.cmp',

		-- use a release tag to download pre-built binaries
		version = '1.*',
		-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
			-- 'super-tab' for mappings similar to vscode (tab to accept)
			-- 'enter' for enter to accept
			-- 'none' for no mappings
			--
			-- All presets have the following mappings:
			-- C-space: Open menu or open docs if already open
			-- C-n/C-p or Up/Down: Select next/previous item
			-- C-e: Hide menu
			-- C-k: Toggle signature help (if signature.enabled = true)
			--
			-- See :h blink-cmp-config-keymap for defining your own keymap
			keymap = { preset = 'default' },

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = 'mono'
			},

			-- (Default) Only show the documentation popup when manually triggered
			completion = { documentation = { auto_show = false } },

			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			sources = {
				default = { 'lsp', 'path', 'buffer' },
			},

			-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
			-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
			-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
			--
			-- See the fuzzy documentation for more information
			fuzzy = { implementation = "prefer_rust_with_warning" }
		},
		opts_extend = { "sources.default" }
	}
})

-- Large workspace scanning may freeze the UI; see https://github.com/neovim/neovim/issues/23291
-- capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

local function stop_lsp_clients()
	vim.lsp.stop_client(vim.lsp.get_clients())
end

vim.api.nvim_create_user_command('LspStop', stop_lsp_clients, {})

-- https://clangd.llvm.org/extensions.html#switch-between-sourceheader
local function switch_source_header(bufnr)
	local method_name = 'textDocument/switchSourceHeader'
	local client = vim.lsp.get_clients({ bufnr = bufnr })[1]
	local params = vim.lsp.util.make_text_document_params(bufnr)
	client.request(method_name, params, function(err, result)
		if err then
			error(tostring(err))
		end
		if not result then
			vim.notify('corresponding file cannot be determined')
			return
		end
		vim.cmd.edit(vim.uri_to_fname(result))
	end, bufnr)
end

local clangd_cmd = {
	"clangd",
	"-header-insertion=never",
}
local is_pigweed = string.find(vim.loop.cwd() or "", "/pigweed")
if is_pigweed then
	clangd_cmd = {
		"/usr/local/google/home/benlawson/pigweed/.environment/cipd/packages/pigweed/bin/clangd",
		"-header-insertion=never",
		-- GN
		"--compile-commands-dir=/usr/local/google/home/benlawson/pigweed/.pw_ide/.stable",
		-- Bazel
		-- "--compile-commands-dir=/usr/local/google/home/benlawson/pigweed/.compile_commands/fuchsia",
		"--query-driver=/usr/local/google/home/benlawson/pigweed/.environment/cipd/packages/pigweed/bin/*,/usr/local/google/home/benlawson/pigweed/.environment/cipd/packages/arm/bin/*",
		"--background-index",
		"--clang-tidy",
	}
end

vim.lsp.config['clangd'] = {
	cmd = clangd_cmd,
	filetypes = { 'h', 'cc', 'cpp', 'cc.inc' },
	root_markers = { '.gn' },
	commands = {
		ClangdSwitchSourceHeader = {
			function()
				-- 0 means current buffer
				switch_source_header(0)
			end,
			description = 'Switch between source/header',
		},
	}
}
vim.lsp.enable('clangd')

vim.lsp.config['rust_analyzer'] = {
	cmd = { '/usr/local/google/home/benlawson/fuchsia/prebuilt/third_party/rust-analyzer/rust-analyzer' },
	filetypes = { 'rust' },
	root_markers = { '.git' },
	settings = {
		['rust-analyzer'] = {
			diagnostics = {
				enable = true,
				remapPrefix = {
					["../../"] = "~/fuchsia",
				},
				experimental = {
					enable = true,
				}
			},
			check = {
				-- overrideCommand = { "fx", "clippy", "--all", "--raw"}
				overrideCommand = { "fx", "clippy", "-f", "$saved_file", "--raw" }
			},
			cachePriming = {
				enable = false,
			}
		},
	},
}
vim.lsp.enable('rust_analyzer')

vim.lsp.config['luals'] = {
	cmd = { 'lua-language-server' },
	filetypes = { 'lua' },
	root_markers = { '.luarc.json', '.luarc.jsonc' },
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
		}
	}
}
vim.lsp.enable('luals')

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

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Buffer local mappings.
-- See `:help vim.lsp.*` for documentation on any of the below functions
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {})
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
vim.keymap.set('n', 'gr', vim.lsp.buf.references, {})
vim.keymap.set('n', 'gh', vim.lsp.buf.hover, {})
vim.keymap.set('n', 'gk', vim.lsp.buf.signature_help, {})
vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, {})
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})
-- vim.keymap.set('n', '<leader>o', function() vim.cmd('ClangdSwitchSourceHeader') end, {})
vim.keymap.set('n', '<leader>o', function() switch_source_header(0) end, {})
vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, {})
vim.keymap.set('n', '<leader>bf', function()
	vim.lsp.buf.format { async = true }
end, {})

vim.keymap.set('n', '<leader>G', ':DiffviewOpen HEAD~1<CR>', {})


-- LSP format on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	callback = function()
		vim.lsp.buf.format()
	end,
})

-- misc keymaps
vim.keymap.set('n', '<leader>bp', '<C-^>', {})

-- FIDL
vim.filetype.add({ extension = { fidl = "fidl" } })

-- highlight whitespace
vim.opt.listchars = {
	tab = "▏ ",
	trail = "·",
	nbsp = "·"
}
vim.opt.list = true

-- Copy to system clipboard: "+y
vim.g.clipboard = {
	name = 'OSC 52',
	copy = {
		['+'] = require('vim.ui.clipboard.osc52').copy('+'),
		['*'] = require('vim.ui.clipboard.osc52').copy('*'),
	},
	paste = {
		['+'] = require('vim.ui.clipboard.osc52').paste('+'),
		['*'] = require('vim.ui.clipboard.osc52').paste('*'),
	},
}

vim.cmd [[set notermguicolors]]
vim.cmd [[set bg=light]]
vim.cmd [[let g:terminal_color_11 = 'black']]
