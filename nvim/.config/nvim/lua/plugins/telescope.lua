-- plugins/telescope.lua — fuzzy finder

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      -- Native fzf sorter — much faster for large codebases
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function() return vim.fn.executable("make") == 1 end,
    },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>",              desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>",               desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>",                 desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",               desc = "Help tags" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                desc = "Recent files" },
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>",             desc = "Diagnostics" },
    { "<leader>/",  "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Fuzzy find in buffer" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        prompt_prefix = "  ",
        selection_caret = " ",
        path_display = { "truncate" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<esc>"] = actions.close,
          },
        },
      },
    })

    pcall(telescope.load_extension, "fzf")
  end,
}
