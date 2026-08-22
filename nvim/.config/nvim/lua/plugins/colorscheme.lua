-- plugins/colorscheme.lua — Catppuccin, matching VS Code, starship and Ghostty

return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,    -- load immediately so colours are set before other plugins
  priority = 1000, -- load before everything else
  config = function()
    require("catppuccin").setup({
      -- Follow the terminal/system appearance: Latte in light, Mocha in dark.
      -- Ghostty and VS Code switch on the same signal, so `theme-toggle`
      -- flips all three together.
      flavour = "auto",
      background = { light = "latte", dark = "mocha" },
      transparent_background = false,
      -- Match starship.toml, which italicises nothing but reads as a
      -- comment-heavy palette; keep comments italic as before.
      styles = {
        comments = { "italic" },
        conditionals = {},
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        telescope = true,
        indent_blankline = { enabled = true },
        mason = true,
        native_lsp = { enabled = true },
        which_key = true,
      },
    })
    vim.cmd.colorscheme("catppuccin")
  end,
}
