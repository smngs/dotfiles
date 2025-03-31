require('trouble').setup({
  position = 'bottom',
  height = 10,
  width = 50,
  indent_lines = true,
  modes = {
    diagnostics = { auto_open = true },
  },
  auto_close = true,
  auto_preview = true,
  auto_fold = true,
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
