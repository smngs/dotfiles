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

  -- Markdown
  { 
    'MeanderingProgrammer/render-markdown.nvim',
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
      { 'neovim/nvim-lspconfig', },
    },
    config = function()
      require("plugins.mason-lspconfig")
    end,
  },

  { -- mason-null-ls
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
      "nvimtools/none-ls.nvim",
    },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
          sources = {
              null_ls.builtins.diagnostics.textlint.with({
                filetypes = { "markdown", "tex" }
              })
          },
      })
    end,
  },

  {
    'vim-skk/skkeleton',
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
    opts = {}
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

  { -- Snippet
    "lervag/vimtex",
  },

  { -- copilot
    'zbirenbaum/copilot.lua',
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
    config = function()
      require("nvim-surround").setup()
    end
  },

  {
    "yetone/avante.nvim",
    run = "make",
    dependencies = {
      'MeanderingProgrammer/render-markdown.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
      'HakonHarnes/img-clip.nvim',
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim',
    },
    config = function()
      require('img-clip').setup ({
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      })
      require('avante_lib').load()
      require('avante').setup ({
        provider = "openai",
      })
    end
  }
}
