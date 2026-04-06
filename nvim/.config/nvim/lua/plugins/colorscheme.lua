-- plugins/colorscheme.lua — Dracula, matching VS Code + starship palette

return {
  "Mofiqul/dracula.nvim",
  lazy = false,    -- load immediately so colours are set before other plugins
  priority = 1000, -- load before everything else
  config = function()
    require("dracula").setup({
      -- Use italic for comments and keywords
      italic_comment = true,
      -- Transparent background — set false to keep the dark bg
      transparent_bg = false,
      -- Override specific highlight groups to match the Dracula Soft variant
      -- used in VS Code ("Dracula Theme Soft")
      overrides = function(colors)
        return {
          -- Soften the background slightly (Dracula Soft is #22212c vs Dracula's #282a36)
          Normal = { bg = "#22212c" },
          NormalNC = { bg = "#22212c" },
          SignColumn = { bg = "#22212c" },
          NvimTreeNormal = { bg = "#1e1d29" },
        }
      end,
    })
    vim.cmd.colorscheme("dracula")
  end,
}
