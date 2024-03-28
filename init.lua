local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.6' })
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('neovim/nvim-lspconfig', { ['commit'] = 'd67715d3b746a19e951b6b0a99663fa909bb9e64' })
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-cmdline')
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-vsnip')
Plug('hrsh7th/vim-vsnip')
Plug('stevearc/overseer.nvim', {['commit'] = 'b72f6d23ce47ccd427be2341f389c63448278f17'})
Plug('nvim-telescope/telescope-file-browser.nvim', {['commit'] = '8839e3f8070dfafa5b0c0e4652700298e7b872c4'})
Plug('https://gn.googlesource.com/gn', {['rtp'] = 'misc/vim'})
Plug('airblade/vim-gitgutter', {['commit'] = '67ef116100b40f9ca128196504a2e0bc0a2753b0'})
Plug('tpope/vim-fugitive', {['commit'] = '8d4e8d45385c63a0bf735fe1164772116bf0da0d'})
Plug('raimondi/delimitmate', {['commit'] = '537a1da0fa5eeb88640425c37e545af933c56e1b'})
vim.call('plug#end')

-- map leader to <Space>
vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "

-- Git
vim.keymap.set('n', '<leader>gg', function() vim.cmd('Git') end, {})

-- Overseer (VS code tasks)
local overseer = require('overseer')
overseer.setup()
vim.keymap.set('n', '<leader>pt', function() vim.cmd('OverseerRun') end, {})

-- Theme
vim.cmd [[colorscheme eink]]

-- Enable line numbers
vim.wo.number = true

-- Terminal
vim.keymap.set('t', '<C-space>', '<C-\\><C-n>', {}) -- exit terminal mode

-- window keymap
vim.keymap.set('n', '<leader>wh', '<C-w>h', {})
vim.keymap.set('n', '<leader>wj', '<C-w>j', {})
vim.keymap.set('n', '<leader>wk', '<C-w>k', {})
vim.keymap.set('n', '<leader>wl', '<C-w>l', {})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader><leader>', builtin.find_files, {})
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', function() builtin.buffers({sort_mru = true}) end, {})
vim.keymap.set('n', '<leader>bb', function() builtin.buffers({sort_mru = true}) end, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>f.', ':Telescope file_browser path=%:p:h select_buffer=true<CR>', {})
vim.keymap.set('n', '<leader>.', ':Telescope file_browser path=%:p:h select_buffer=true<CR>', {})
vim.keymap.set('n', '<leader>sb', ':Telescope current_buffer_fuzzy_find<CR>', {})
vim.keymap.set('n', '<leader>ss', ':Telescope current_buffer_fuzzy_find<CR>', {})
vim.keymap.set('n', '<leader>fbd', function() builtin.find_files({ cwd = require('telescope.utils').buffer_dir() }) end, {})
require('telescope').load_extension('file_browser')

-- Treesitter
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

-- Set up nvim-cmp.
local cmp = require'cmp'
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
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
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

-- Capabilities for lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

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
lspconfig.rust_analyzer.setup {
  capabilities = capabilities,
  -- Server-specific settings. See `:help lspconfig-setup`
  settings = {
    ['rust-analyzer'] = {
	diagnostics = {
 		remapPrefix = {
			["../../"] = "~/fuchsia",
		}
	}
    },
  },
}
lspconfig.starlark_rust.setup{
  capabilities = capabilities,
}

-- LSP format on save
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Buffer local mappings.
-- See `:help vim.lsp.*` for documentation on any of the below functions
local opts = {}
vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, opts)
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
-- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
-- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
-- vim.keymap.set('n', '<space>wl', function()
--   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
-- end, opts)
vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
vim.keymap.set('n', '<space>f', function()
  vim.lsp.buf.format { async = true }
end, opts)

-- FIDL
vim.filetype.add({ extension = { fidl = "fidl" } })

-- Don't wrap lines
vim.wo.wrap = false

vim.cmd [[set notermguicolors]]
vim.cmd [[set bg=light]]
