-- plugins/cmp.lua — completion engine

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",   -- LSP completions
    "hrsh7th/cmp-buffer",      -- current buffer words
    "hrsh7th/cmp-path",        -- filesystem paths
    "L3MON4D3/LuaSnip",       -- snippet engine (required by cmp)
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Tabout: <Tab> past the next closing delimiter, mirroring LaTeX Suite's
    -- taboutClosingSymbols. Multi-character entries are why this is a plain
    -- string scan rather than a bracket-pair match.
    local TABOUT = {
      ")", "]", "}", "\\rbrack", "\\}", "\\rbrace", "\\rangle",
      "\\rvert", "\\rVert", "\\rfloor", "\\rceil", "\\urcorner",
    }

    local function tabout()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local best
      for _, sym in ipairs(TABOUT) do
        local from = line:find(sym, col + 1, true)
        if from and (not best or from < best) then best = from end
      end
      if not best then return false end
      -- Jump past the longest symbol starting at that position (\rVert before }).
      local width = 0
      for _, sym in ipairs(TABOUT) do
        if line:sub(best, best + #sym - 1) == sym then width = math.max(width, #sym) end
      end
      vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), best + width - 1 })
      return true
    end

    cmp.setup({
      snippet = {
        expand = function(args) luasnip.lsp_expand(args.body) end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"]     = cmp.mapping.select_prev_item(),
        ["<C-j>"]     = cmp.mapping.select_next_item(),
        ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
        ["<C-f>"]     = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"]     = cmp.mapping.abort(),
        ["<CR>"]      = cmp.mapping.confirm({ select = false }),
        ["<Tab>"]     = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif vim.bo.filetype == "tex" and tabout() then
            return
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"]   = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip",  priority = 750 },
        { name = "buffer",   priority = 500 },
        { name = "path",     priority = 250 },
      }),
    })
  end,
}
