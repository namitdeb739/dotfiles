-- plugins/tools.lua — terminal, undo history, sessions, git history

return {
  -- The integrated terminal. <C-\> toggles a float; <leader>tg opens lazygit
  -- if it's installed, otherwise the mapping is simply absent.
  {
    "akinsho/toggleterm.nvim",
    keys = {
      { [[<C-\>]], desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Split terminal" },
    },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "float",
      float_opts = { border = "rounded" },
      shade_terminals = true,
      -- terminal.integrated.enablePersistentSessions
      persist_size = true,
      persist_mode = true,
    },
  },

  -- undofile is on, but there was no way to browse the tree it writes.
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle undo tree" },
    },
    init = function()
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },

  -- Reopen a directory with its buffers and layout intact.
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    keys = {
      { "<leader>ss", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>sd", function() require("persistence").stop() end, desc = "Don't save session" },
    },
    opts = {},
  },

  -- donjayamanne.githistory + the diff half of GitLens; gitsigns keeps hunks.
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diff view" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
    },
  },
}
