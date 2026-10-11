-- plugins/format.lua — format-on-save and linting, matching the VS Code setup
-- (editor.formatOnSave + source.fixAll.ruff + source.organizeImports.ruff).

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>lf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          -- ruff_organize_imports before ruff_format, mirroring the order
          -- codeActionsOnSave applies them in.
          python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
          lua = { "stylua" },
          json = { "prettier" },
          jsonc = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          sh = { "shfmt" },
          bash = { "shfmt" },
        },
        format_on_save = function(bufnr)
          -- vimtex owns .tex; a formatter would fight the snippet output.
          if vim.bo[bufnr].filetype == "tex" then return nil end
          return { timeout_ms = 1000, lsp_format = "fallback" }
        end,
        -- Missing formatter binaries are a config problem, not a save-time
        -- error message on every write.
        notify_on_error = false,
      })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- basedpyright already type-checks; mypy is the second opinion VS Code
      -- runs via ms-python.mypy-type-checker. Only wire it up where it exists,
      -- since projects that disable mypy have no binary on PATH.
      lint.linters_by_ft = {
        python = vim.fn.executable("mypy") == 1 and { "mypy" } or {},
        markdown = vim.fn.executable("markdownlint") == 1 and { "markdownlint" } or {},
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
        callback = function() lint.try_lint() end,
      })
    end,
  },
}
