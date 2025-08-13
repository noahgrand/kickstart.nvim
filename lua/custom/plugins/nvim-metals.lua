return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-vsnip' },
      { 'hrsh7th/vim-vsnip' },
    },
    opts = function()
      local cmp = require 'cmp'
      local conf = {
        sources = {
          { name = 'nvim_lsp' },
          { name = 'vsnip' },
        },
        snippet = {
          expand = function(args)
            -- Comes from vsnip
            vim.fn['vsnip#anonymous'](args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          -- None of this made sense to me when first looking into this since there
          -- is no vim docs, but you can't have select = true here _unless_ you are
          -- also using the snippet stuff. So keep in mind that if you remove
          -- snippets you need to remove this select
          ['<CR>'] = cmp.mapping.confirm { select = true },
        },
      }
      return conf
    end,
  },
  {
    'scalameta/nvim-metals',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'j-hui/fidget.nvim',
        opts = {},
      },
      {
        'mfussenegger/nvim-dap',
        config = function(self, opts)
          -- Debug settings if you're using nvim-dap
          local dap = require 'dap'

          dap.configurations.scala = {
            {
              type = 'scala',
              request = 'launch',
              name = 'RunOrTest',
              metals = {
                runType = 'runOrTestFile',
                --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
              },
            },
            {
              type = 'scala',
              request = 'launch',
              name = 'Test Target',
              metals = {
                runType = 'testTarget',
              },
            },
          }
        end,
      },
    },
    ft = { 'scala', 'sbt', 'java', 'lua' },
    opts = function()
      local metals_config = require('metals').bare_config()

      -- Example of settings
      metals_config.settings = {
        showImplicitArguments = true,
      }

      metals_config.init_options.statusBarProvider = 'off'

      -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
      metals_config.capabilities = require('cmp_nvim_lsp').default_capabilities()

      metals_config.on_attach = function(client, bufnr)
        require('metals').setup_dap()
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-t>.
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

        --  -- Find references for the word under your cursor.
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

        --  -- Jump to the implementation of the word under your cursor.
        --  --  Useful when your language has ways of declaring types without an actual implementation.
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

        --  -- Jump to the type of the word under your cursor.
        --  --  Useful when you're not sure what type a variable is and you want to see
        --  --  the definition of its *type*, not where it was *defined*.
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

        --  -- Fuzzy find all the symbols in your current document.
        --  --  Symbols are things like variables, functions, types, etc.
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

        --  -- Fuzzy find all the symbols in your current workspace.
        --  --  Similar to document symbols, except searches over your entire project.
        --        map('<leader>ws', require('metals').hover_worksheet(), '[W]orkspace [S]ymbols')

        --  -- Rename the variable under your cursor.
        --  --  Most Language Servers support renaming across files, etc.
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

        --  -- Execute a code action, usually your cursor needs to be on top of an error
        --  -- or a suggestion from your LSP for this to activate.
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

        --  -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  --  For example, in C this would take you to the header.
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      end

      return metals_config
    end,
    config = function(self, metals_config)
      local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = self.ft,
        callback = function()
          require('metals').initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end,
  },
}
