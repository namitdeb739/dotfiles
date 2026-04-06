-- plugins/lsp.lua — mason + lspconfig + mason-lspconfig

-- Servers to auto-install and configure
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
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = { border = "rounded" },
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Shared on_attach: keymaps available in any LSP buffer
      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
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
      end

      -- Configure each server
      for server, opts in pairs(servers) do
        opts.capabilities = capabilities
        opts.on_attach = on_attach
        lspconfig[server].setup(opts)
      end

      -- Diagnostic signs
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded" },
      })
    end,
  },
}
