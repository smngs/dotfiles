require("telescope").setup({
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case"
    },
    file_browser = {
      hijack_netrw = true
    }
  }
})
require("telescope").load_extension "lazy"

local builtin = require("telescope.builtin")
vim.keymap.set('n', 'ge', builtin.find_files, { noremap = true })
