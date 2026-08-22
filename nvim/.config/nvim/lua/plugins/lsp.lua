-- plugins/lsp.lua — mason + lspconfig + mason-lspconfig

-- Servers to auto-install and configure. Keys are lspconfig server names.
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  bashls = {},
  basedpyright = {},
}

return {
  {
    -- mason moved from williamboman/ to mason-org/ at v2.
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = { border = "rounded" },
      })
    end,
  },

  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        -- v2 replaced `automatic_installation` with `automatic_enable`, which
        -- calls vim.lsp.enable() for every installed server.
        automatic_enable = true,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Neovim 0.11 deprecated the `require('lspconfig')[server].setup()`
      -- framework; it will be removed in nvim-lspconfig v3.0.0. Configuration
      -- now goes through vim.lsp.config, which merges over the defaults that
      -- nvim-lspconfig ships in lsp/<name>.lua.
      vim.lsp.config("*", { capabilities = capabilities })

      for server, opts in pairs(servers) do
        if not vim.tbl_isempty(opts) then
          vim.lsp.config(server, opts)
        end
      end

      vim.lsp.enable(vim.tbl_keys(servers))

      -- Keymaps attach per-buffer when a server connects, replacing the
      -- per-server on_attach the old framework passed through.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_attach_keymaps", { clear = true }),
        callback = function(ev)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = desc })
          end

          map("gd",         vim.lsp.buf.definition,      "Go to definition")
          map("gD",         vim.lsp.buf.declaration,     "Go to declaration")
          map("gr",         vim.lsp.buf.references,      "References")
          map("gI",         vim.lsp.buf.implementation,  "Go to implementation")
          map("K",          vim.lsp.buf.hover,            "Hover docs")
          map("<C-k>",      vim.lsp.buf.signature_help,  "Signature help")
          map("<leader>lr", vim.lsp.buf.rename,           "Rename symbol")
          map("<leader>la", vim.lsp.buf.code_action,     "Code action")
          map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format")
        end,
      })

      vim.diagnostic.config({
        virtual_text = true,
        -- Signs move into vim.diagnostic.config here; defining DiagnosticSign*
        -- via vim.fn.sign_define has been deprecated since 0.10.
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = "󰠠 ",
            [vim.diagnostic.severity.INFO]  = " ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded" },
      })
    end,
  },
}
