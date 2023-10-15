return {
 { -- Japanese Help
  'vim-jp/vimdoc-ja',
 },

 { -- colorscheme
   'cocopon/iceberg.vim',
   config = function()
     vim.cmd([[colorscheme iceberg]])
   end
 },

 { -- Status Line
   'nvim-lualine/lualine.nvim',
   requires = { 'nvim-tree/nvim-web-devicons', opt = true },
   config = function()
     require('lualine').setup()
   end
 },

 { -- Mode to Column Line
  'mvllow/modes.nvim',
  config = function()
    require('modes').setup({
      colors =  {
        visual = "#d9a67f"
      }
    })
  end
 },

 { -- Filer
   'lambdalisue/fern.vim',
   config = function()
     vim.cmd([[
       autocmd StdinReadPre * let s:std_in=1
       autocmd VimEnter * ++nested Fern . -drawer | if argc() > 0 || exists("s:std_in") | wincmd p | endif
     ]])
   end,
   dependencies = {
     { 'lambdalisue/fern-git-status.vim', },
     { 'lambdalisue/nerdfont.vim', },
     {
       'lambdalisue/fern-renderer-nerdfont.vim',
       config = function()
         vim.g['fern#renderer'] = "nerdfont"
       end
     },
     { 'lambdalisue/glyph-palette.vim', },
   } ,
 },

 { -- Bar (Buffer)
  'romgrk/barbar.nvim',
  dependencies = {
    { 'lewis6991/gitsigns.nvim', },
    { 'nvim-tree/nvim-web-devicons', },
  },
  config = function()
    vim.api.nvim_set_keymap('n', '<C-j>', '<Cmd>BufferPrevious<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<C-k>', '<Cmd>BufferNext<CR>', { noremap = true, silent = true })
  end
 },

 { -- fuzzy finder (telescope)
  'nvim-telescope/telescope.nvim',
  dependencies = {
   {'nvim-lua/plenary.nvim', },
   {'tsakirist/telescope-lazy.nvim', },
   {'nvim-telescope/telescope-file-browser.nvim', },
  },
  config = function()
    require("plugins.telescope")
  end
 },

 { -- Treesitter
   'nvim-treesitter/nvim-treesitter',
   config = function()
     require("plugins.nvim-treesitter")
   end
 },

 -- LSP
 { -- Mason
   'williamboman/mason.nvim',
 },
 { --Mason-lspconfig
   'williamboman/mason-lspconfig.nvim',
   dependencies = {
     {
       'williamboman/mason.nvim',
       config = function()
        require('mason').setup()
       end
     },
     {'neovim/nvim-lspconfig', },
   },
   config = function()
     require("plugins.mason-lspconfig")
   end,
 },

 { -- nvim-cmp
  "hrsh7th/nvim-cmp",
  dependencies = {
    {"hrsh7th/cmp-nvim-lsp", },
    {"onsails/lspkind.nvim", },
    {"hrsh7th/cmp-nvim-lsp-signature-help", },
    {"hrsh7th/cmp-nvim-lsp-document-symbol", },
    {"hrsh7th/cmp-path", },
    {"ray-x/cmp-treesitter", },
    {"Maan2003/lsp_lines.nvim", },
  },
  config = function()
    require("plugins.nvim-cmp")
  end
 },

 { -- Snippet
   "L3MON4D3/LuaSnip",
   dependencies = {
     {'saadparwaiz1/cmp_luasnip',},
     {
       'rafamadriz/friendly-snippets',
       config = function()
         require("luasnip/loaders/from_vscode").lazy_load()
       end
     },
     {'saadparwaiz1/cmp_luasnip',},
   },
   config = function()
     require("luasnip.loaders.from_vscode").lazy_load({ paths = {"./snippets"} })
   end
 },

 { --Git
  "lewis6991/gitsigns.nvim",
  config = function()
    require("plugins.gitsigns")
  end
 },

 { -- Print diagnostics
  "folke/trouble.nvim",
  config = function()
    require("plugins.trouble")
  end
 },

 { -- nvim-surround (edit brace)
  'kylechui/nvim-surround',
  config = function ()
    require("nvim-surround").setup()
  end
 }
}
