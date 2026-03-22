return {
  { -- Japanese Help
    'vim-jp/vimdoc-ja',
    lazy = true,
  },

  { -- colorscheme
    'cocopon/iceberg.vim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme iceberg]])
    end
  },

  { -- Status Line
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('plugins.lualine')
    end
  },

  { -- Mode to Column Line
    'mvllow/modes.nvim',
    event = "VeryLazy",
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
    cmd = { 'Fern' },
    keys = {
      { '<leader>e', '<cmd>Fern . -reveal=%<cr>', desc = 'Open Fern' },
    },
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
    },
  },

  -- { -- Bar (Buffer)
  --   'romgrk/barbar.nvim',
  --   dependencies = {
  --     { 'lewis6991/gitsigns.nvim', },
  --     { 'nvim-tree/nvim-web-devicons', },
  --   },
  --   config = function()
  --     vim.api.nvim_set_keymap('n', '<C-j>', '<Cmd>BufferPrevious<CR>', { noremap = true, silent = true })
  --     vim.api.nvim_set_keymap('n', '<C-k>', '<Cmd>BufferNext<CR>', { noremap = true, silent = true })
  --   end
  -- },

  { -- fuzzy finder (telescope)
    'nvim-telescope/telescope.nvim',
    cmd = { 'Telescope' },
    keys = {
      { 'ge', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Live grep' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },
    },
    dependencies = {
      { 'nvim-lua/plenary.nvim', },
      { 'tsakirist/telescope-lazy.nvim', },
      { 'nvim-telescope/telescope-file-browser.nvim', },
    },
    config = function()
      require("plugins.telescope")
    end
  },

  -- Markdown
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { "markdown", "Avante" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require('render-markdown').setup ({
        file_types = { "Avante" },
      })
    end
  },

  -- LSP
  { -- Mason
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonUpdate' },
  },

  { --Mason-lspconfig
    'williamboman/mason-lspconfig.nvim',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        'williamboman/mason.nvim',
        config = function()
          require('mason').setup()
        end
      },
      { 'neovim/nvim-lspconfig', },
    },
    config = function()
      require("plugins.mason-lspconfig")
    end,
  },

  -- { -- mason-null-ls
  --   "jay-babu/mason-null-ls.nvim",
  --   dependencies = {
  --     "nvimtools/none-ls.nvim",
  --   },
  --   config = function()
  --     local null_ls = require("null-ls")
  --     null_ls.setup({
  --         sources = {
  --             null_ls.builtins.diagnostics.textlint.with({
  --               filetypes = { "markdown", "tex" }
  --             })
  --         },
  --     })
  --   end,
  -- },

  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function()
      vim.g.rustfmt_autosave = 1
      vim.g.rustfmt_options = '--edition 2024'
    end
  },

  { -- IME auto switch (fcitx5)
    'keaising/im-select.nvim',
    event = { "InsertLeave", "CmdlineLeave" },
    config = function()
      require('im_select').setup({
        default_command = 'fcitx5-remote',
        default_im_select = '1',
        set_default_events = { 'VimEnter', 'FocusGained', 'InsertLeave', 'CmdlineLeave' },
        set_previous_events = { 'InsertEnter' },
      })
    end
  },

  { -- SKK (Input Method)
    'vim-skk/skkeleton',
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "vim-denops/denops.vim",
      "rinx/cmp-skkeleton"
    },
    config = function()
      vim.fn["skkeleton#config"]({
        globalDictionaries = { '~/dotfiles/skk/SKK-JISYO.L' },
        eggLikeNewline = true,
        keepState = true,
        sources = { "google_japanese_input" }
      })
      vim.fn["skkeleton#register_kanatable"]("rom", {
        [","] = {"，", ""},
        ["."] = {"．", ""}
      })
      vim.fn["skkeleton#register_kanatable"]("rom", {
        ["jj"] = "escape",
      })
      vim.keymap.set('i', '<C-j>', '<Plug>(skkeleton-enable)', { silent = true })
      vim.keymap.set('c', '<C-j>', '<Plug>(skkeleton-enable)', { silent = true })
    end
  },

  {
    "delphinus/skkeleton_indicator.nvim",
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {}
  },

  { -- nvim-cmp
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp", },
      { "onsails/lspkind.nvim", },
      { "hrsh7th/cmp-nvim-lsp-signature-help", },
      { "hrsh7th/cmp-nvim-lsp-document-symbol", },
      { "hrsh7th/cmp-path", },
      { "ray-x/cmp-treesitter", },
    },
    config = function()
      require("plugins.nvim-cmp")
    end
  },

  { -- Snippet
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    dependencies = {
      { 'saadparwaiz1/cmp_luasnip', },
      {
        'rafamadriz/friendly-snippets',
        config = function()
          require("luasnip/loaders/from_vscode").lazy_load()
        end
      },
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = {"./snippets"} })
    end
  },

  { -- LaTeX
    "lervag/vimtex",
    ft = { "tex", "latex" },
    init = function()
      if vim.fn.has("mac") == 1 then
        -- vim.g.vimtex_view_method = "skim"
        vim.g.vimtex_view_method = "zathura"
      else
        vim.g.vimtex_view_method = "zathura"
      end
    end,
  },

  { -- copilot
    'zbirenbaum/copilot.lua',
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
        copilot_node_command = 'node'
      })
    end
  },

  { -- Git
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("plugins.gitsigns")
    end
  },

  { -- nvim-treesitter
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      require("plugins.nvim-treesitter")
    end
  },

  { -- Print diagnostics
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Trouble' },
    },
    config = function()
      require("plugins.trouble")
    end
  },

  { -- Claude Code
    'greggh/claude-code.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'ClaudeCode', 'ClaudeCodeContinue' },
    keys = {
      { '<leader>cc', desc = 'Toggle Claude Code' },
    },
    config = function()
      require('plugins.claude-code')
    end
  },

  { -- nvim-surround (edit brace)
    'kylechui/nvim-surround',
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end
  }
}
