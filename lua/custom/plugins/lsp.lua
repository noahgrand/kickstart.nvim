return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      require('lspconfig').pyright.setup {}
      require('lspconfig')['tinymist'].setup {
        settings = {
          formatterMode = 'typstyle',
          exportPdf = 'never',
          semanticTokens = 'disable',
        },
      }
    end,
  },
}
