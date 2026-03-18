local mason_lspconfig = require("mason-lspconfig");
local lspconfig = require("lspconfig")

require('mason-lspconfig').setup({
  ensure_installed = {
    'clangd',
    'denols',
    'dockerls',
    'jsonls',
    -- 'texlab',
    'pyright',
    'rust_analyzer',
  },
  automatic_installation = true
})

-- local pio_driver = vim.fn.expand("~/.platformio/packages/**/bin/*")
-- 
-- vim.lsp.config("clangd", {
--   cmd = {
--     "clangd",
--     "--background-index",
--     "--clang-tidy",
--     "--completion-style=detailed",
--     "--query-driver=" .. pio_driver,
--   },
-- })


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
