require('trouble').setup({
  position = 'bottom',
  height = 10,
  widht = 50,
  icons = true,
  mode ='workspace_diagnostics',
  indent_lines = true,
  opts = {
    modes = {
      diagnostics = { auto_open = true },
    }
  },
  auto_close = true,
  auto_preview = true,
  auto_fold = false,
  auto_jump = {'lsp_definitions'},
  signs = {
    error = 'E',
    warning = 'W',
    hint = 'H',
    information = 'I',
    other = 'O'
  },
  use_diagnostic_signs = true
})
