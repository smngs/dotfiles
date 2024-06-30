require('mason-lspconfig').setup({
  ensure_installed = {
    'clangd',
    'denols',
    'dockerls',
    'jsonls',
    -- 'texlab',
    'remark_ls',
    'pyright',
    'rust_analyzer',
    'tsserver'
  },
  automatic_installation = true
})

-- Display error/warnings as hover.
vim.o.updatetime = 200
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("float_diagnostic", { clear = true }),
  callback = function ()
    vim.diagnostic.open_float(nil, {focus=false})
  end
})

vim.diagnostic.config({
  virtual_text = false
})
