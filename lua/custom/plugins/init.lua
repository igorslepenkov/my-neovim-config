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
              context = { diagnostics = {}, only = { 'source.addMissingImports' } },
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
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
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

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
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
        gopls = {},
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
      vim.lsp.config('fish_lsp', {})

      require('mason').setup()

      local mason_lspconfig = require 'mason-lspconfig'
      mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
      }

      for server_name, server_opts in pairs(servers) do
        vim.lsp.config(
          server_name,
          vim.tbl_deep_extend('force', {
            capabilities = capabilities,
          }, server_opts)
        )
        vim.lsp.enable(server_name)
      end

      vim.lsp.config('denols', {
        root_dir = function(fname, on_dir)
          local util = require 'lspconfig.util'
          local ts_root = util.root_pattern 'package.json'(fname)
          local deno_root = util.root_pattern('deno.json', 'deno.jsonc')(fname)

          if deno_root and not ts_root then
            on_dir(deno_root)
          end

          return false
        end,
        workspace_required = true,
      })

      vim.lsp.enable 'denols'

      vim.lsp.config('ts_ls', {
        root_dir = function(fname, on_dir)
          local util = require('lspconfig').util
          local ts_root = util.root_pattern 'package.json'(fname)

          if ts_root then
            on_dir(ts_root)
          else
            on_dir(vim.fn.fnamemodify(fname, ':h'))
          end
        end,
        workspace_required = false,
      })
    end,

    vim.lsp.enable 'ts_ls',
  },
  {
    'ravitemer/mcphub.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim', -- For async support
    },
    build = 'npm install -g mcp-hub@latest', -- Core MCP Hub server
    config = function()
      require('mcphub').setup {
        port = 37373,
        config = vim.fn.expand '~/.config/mcphub/servers.json',
        log = {
          level = vim.log.levels.WARN,
          to_file = true, -- Logs at ~/.local/state/nvim/mcphub.log
        },
        on_ready = function()
          vim.notify 'MCP Hub is online!'
        end,
        make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
        show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
        add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
        show_result_in_chat = true, -- Show tool results directly in chat buffer
        format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
        make_vars = true, -- Convert MCP resources to #variables for prompts
        make_slash_commands = true,
      }
    end,
  },
  {
    'olimorris/codecompanion.nvim',
    version = '17.33.0',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    lazy = false,
    keys = {
      {
        '<C-a>',
        '<cmd>CodeCompanionActions<CR>',
        desc = 'Open the action palette',
        mode = { 'n', 'v' },
      },
      {
        '<Leader>a',
        '<cmd>CodeCompanionChat Toggle<CR>',
        desc = 'Toggle a chat buffer',
        mode = { 'n', 'v' },
      },
      {
        '<LocalLeader>a',
        '<cmd>CodeCompanionChat Add<CR>',
        desc = 'Add code to a chat buffer',
        mode = { 'v' },
      },
    },
    init = function()
      vim.cmd [[cab cc CodeCompanion]]
    end,
    opts = {
      opts = {
        log_level = 'TRACE',
      },
      adapters = {
        http = {
          searxng = function()
            local fmt = string.format
            ---@class CodeCompanion.HTTPAdapter
            return {
              name = 'searxng',
              formatted_name = 'SearxNG',
              roles = {
                llm = 'assistant',
                user = 'user',
              },
              opts = {},
              url = '${url}/search',
              env = {
                url = 'SEARXNG_URL',
              },
              headers = {
                ['Content-Type'] = 'application/json',
                ['Accept'] = 'application/json',
              },
              schema = {
                timeout = {
                  default = 10000,
                  description = 'Request timeout in milliseconds',
                },
                categories = {
                  default = 'general',
                  description = 'Search categories (general, news, science, etc.)',
                },
                language = {
                  default = 'en',
                  description = 'Search language',
                },
                model = {
                  default = 'searxng',
                },
              },
              handlers = {},
              methods = {
                tools = {
                  search_web = {
                    ---Setup the adapter for the search web tool
                    ---@param self CodeCompanion.HTTPAdapter
                    ---@param opts table Tool options
                    ---@param data table The data from the LLM's tool call
                    ---@return nil
                    setup = function(self, opts, data)
                      opts = opts or {}
                      local base_url = self.url

                      local utils = require 'codecompanion.utils.adapters'

                      utils.get_env_vars(self)

                      if self.env_replaced and self.env_replaced.url then
                        base_url = self.env_replaced.url
                      end

                      base_url = base_url .. '/search'

                      local query_params = {
                        q = data.query,
                        format = 'json',
                        categories = opts.categories or self.schema.categories.default,
                        language = opts.language or self.schema.language.default,
                        pageno = opts.page or 1,
                      }

                      local url_with_params = base_url
                      local first_param = true

                      for key, value in pairs(query_params) do
                        if first_param then
                          url_with_params = url_with_params .. '?' .. key .. '=' .. tostring(value)
                          first_param = false
                        else
                          url_with_params = url_with_params .. '&' .. key .. '=' .. tostring(value)
                        end
                      end

                      self.url = url_with_params
                    end,

                    ---Process the output from the search web tool
                    ---@param _ CodeCompanion.HTTPAdapter
                    ---@param data table The data returned from the search
                    ---@return table{status: string, content: string}|nil
                    callback = function(_, data)
                      local ok, body = pcall(vim.json.decode, data.body)

                      if not ok then
                        return {
                          status = 'error',
                          content = 'Could not parse JSON response from SearxNG',
                        }
                      end

                      if data.status ~= 200 then
                        return {
                          status = 'error',
                          content = fmt('Error %s - %s', data.status, body.message or 'Unknown error'),
                        }
                      end

                      if body.results == nil or #body.results == 0 then
                        return {
                          status = 'error',
                          content = 'No search results found',
                        }
                      end

                      local output = {}
                      for _, result in ipairs(body.results) do
                        table.insert(output, {
                          content = result.content or '',
                          title = result.title or '',
                          url = result.url or '',
                          engine = result.engine or 'unknown',
                          score = result.score or 0,
                        })
                      end

                      return {
                        status = 'success',
                        content = output,
                      }
                    end,
                  },
                },
              },
            }
          end,
          deepseek = function()
            return require('codecompanion.adapters').extend('deepseek', {
              schema = {
                model = {
                  default = 'deepseek-chat',
                },
                servers = {
                  {
                    name = 'filesystem',
                    command = '/home/igor/.nvm/versions/node/v24.5.0/bin/mcp-server-filesystem',
                    args = {
                      vim.fn.getcwd(),
                    },
                  },
                },
              },
            })
          end,
        },
      },
      strategies = {
        agent = { adapter = 'deepseek' },
        chat = {
          adapter = 'deepseek',
          tools = {
            search_web = {
              opts = {
                adapter = 'searxng',
              },
            },
            ['mcp'] = {
              callback = function()
                return require 'mcphub.extensions.codecompanion'
              end,
              opts = {
                requires_approval = true,
                temperature = 0.7,
              },
            },
          },
        },
        inline = { adapter = 'deepseek' },
      },
    },
  },
}
