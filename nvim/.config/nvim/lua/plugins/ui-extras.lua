-- plugins/ui-extras.lua — the VS Code UI affordances lualine/nvim-tree don't
-- cover: sticky scroll, breadcrumbs, editor tabs, bracket colours, todo tree.

return {
  -- editor.stickyScroll.enabled — pin the enclosing \section or function
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      max_lines = 3,
      multiline_threshold = 1,
      separator = "─",
    },
  },

  -- breadcrumbs.enabled — LSP symbol path in the winbar
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
    keys = {
      { "<leader>bp", function() require("dropbar.api").pick() end, desc = "Pick breadcrumb" },
    },
  },

  -- The editor tab bar, with workbench.editor.highlightModifiedTabs behaviour
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- A function, not a table: the catppuccin groups module only exists once
    -- catppuccin has loaded, which is after this spec file is read.
    opts = function()
      return {
        options = {
          diagnostics = "nvim_lsp",
          separator_style = "thin",
          show_buffer_close_icons = false,
          offsets = {
            { filetype = "NvimTree", text = "Explorer", highlight = "Directory" },
          },
        },
        highlights = require("catppuccin.special.bufferline").get_theme(),
      }
    end,
  },

  -- editor.guides.bracketPairs + bracketPairColorization
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("rainbow-delimiters.setup").setup({})
    end,
  },

  -- gruntfuggly.todo-tree
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
    },
    opts = { signs = false },
  },
}
