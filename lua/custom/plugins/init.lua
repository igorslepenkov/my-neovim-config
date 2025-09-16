-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'xiyaowong/transparent.nvim',
  },
  {
    'tpope/vim-fugitive',
  },
  {
    'sindrets/diffview.nvim',
  },
  {
    'christoomey/vim-tmux-navigator',
    keys = {
      { '<c-j>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-;>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },
  {
    'mbbill/undotree',
    config = function()
      vim.keymap.set('n', '<leader><F5>', vim.cmd.UndotreeToggle)
    end,
  },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
    config = function()
      vim.o.foldcolumn = '1' -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      require('ufo').setup {
        provider_selector = function()
          return { 'lsp', 'indent' }
        end,
      }
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },

      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          vim.keymap.set('n', '<leader>oi', function()
            local params = {
              context = { only = { 'source.organizeImports' } },
              apply = true,
            }
            vim.lsp.buf.code_action(params)
          end, { desc = 'Organize Imports' })

          vim.keymap.set('n', '<leader>ai', function()
            vim.lsp.buf.code_action {
              context = { only = { 'source.addMissingImports' } },
              apply = true,
            }
          end, { desc = 'Auto-add all missing imports' })

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Change diagnostic symbols in the sign column (gutter)
      if vim.g.have_nerd_font then
        local hl = 'DiagnosticSign'

        local signs_text = {
          [vim.diagnostic.severity.ERROR] = '',
          [vim.diagnostic.severity.WARN] = '',
          [vim.diagnostic.severity.HINT] = '',
          [vim.diagnostic.severity.INFO] = '',
        }

        local signs_hl = {
          [vim.diagnostic.severity.ERROR] = hl,
          [vim.diagnostic.severity.WARN] = hl,
          [vim.diagnostic.severity.HINT] = hl,
          [vim.diagnostic.severity.INFO] = hl,
        }

        vim.diagnostic.config {
          signs = {
            text = signs_text,
            numhl = signs_hl,
          },
        }
      end

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/

      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      local servers = {
        pyright = {},
        rust_analyzer = {},
        prismals = {},
        -- tailwindcss = {},
        bashls = {},
        html = {
          filetypes = { 'html', 'templ', 'typescriptreact', 'javascriptreact' },
        },
        clangd = {},
        sqlls = {},
        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Setup fish lsp
      require('lspconfig').fish_lsp.setup {}

      require('mason').setup()

      local mason_lspconfig = require 'mason-lspconfig'
      mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
      }

      local lsp = require 'lspconfig'

      for server_name, server_opts in pairs(servers) do
        lsp[server_name].setup(vim.tbl_deep_extend('force', {
          capabilities = capabilities,
        }, server_opts))
      end

      lsp.denols.setup {
        root_dir = require('lspconfig').util.root_pattern('deno.json', 'deno.jsonc'),
      }

      lsp.ts_ls.setup {
        root_dir = function(fname)
          local util = require('lspconfig').util
          local ts_root = util.root_pattern 'package.json'(fname)
          local deno_root = util.root_pattern('deno.json', 'deno.jsonc')(fname)

          if deno_root and ts_root and deno_root == ts_root then
            return nil
          end

          return ts_root
        end,
        single_file_support = true,
      }
    end,
  },
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      opts = {
        log_level = 'DEBUG',
      },
      adapters = {
        http = {
          ai_mediator = function()
            return require('codecompanion.adapters').extend('openai_compatible', {
              name = 'ai_mediator',
              formatted_name = 'AI Mediator',
              env = {
                url = 'https://api.ai-mediator.ru',
                chat_url = '/v1/chat/completions',
              },
              schema = {
                model = {
                  default = 'gpt-5',
                },
              },
            })
          end,
        },
      },
      strategies = {
        agent = { adapter = 'ai_mediator' },
        chat = { adapter = 'ai_mediator' },
        inline = { adapter = 'ai_mediator' },
      },
    },
  },
}
