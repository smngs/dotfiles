require('mason-lspconfig').setup({
  ensure_installed = {
    'clangd',
    'denols',
    'dockerls',
    'html',
    'jsonls',
    'texlab',
    'remark_ls',
    'pyright',
    'rust_analyzer',
    'tsserver'
  },
  automatic_installation = true
})
