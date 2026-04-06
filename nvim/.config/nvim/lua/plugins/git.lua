-- plugins/git.lua — git signs and blame in the gutter

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Prev hunk")

        -- Actions
        map("n", "<leader>gs", gs.stage_hunk,         "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk,         "Reset hunk")
        map("n", "<leader>gS", gs.stage_buffer,       "Stage buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk,    "Undo stage hunk")
        map("n", "<leader>gR", gs.reset_buffer,       "Reset buffer")
        map("n", "<leader>gp", gs.preview_hunk,       "Preview hunk")
        map("n", "<leader>gb", gs.toggle_current_line_blame, "Toggle blame")
        map("n", "<leader>gd", gs.diffthis,           "Diff this")
      end,
    })
  end,
}
