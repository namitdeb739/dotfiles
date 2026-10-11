-- plugins/luasnip.lua — snippet engine + the Obsidian LaTeX Suite port

return {
  "L3MON4D3/LuaSnip",
  -- jsregexp backs trigEngine="ecma"; the ported triggers use JS regex syntax
  -- (lookbehind included), which Lua patterns cannot express.
  build = "make install_jsregexp",
  config = function()
    local ls = require("luasnip")

    ls.setup({
      enable_autosnippets = true,
      store_selection_keys = "<Tab>", -- <Tab> in visual mode feeds ${VISUAL}
      update_events = "TextChanged,TextChangedI",
      -- With autosnippets firing on nearly every keystroke, leaving a snippet
      -- by accident is common; history lets <S-Tab> jump back into it.
      history = true,
      delete_check_events = "TextChanged", -- drop snippets whose text is gone
    })

    local suite = require("snippets.latex_suite")
    local snippets, autosnippets = suite.build(require("snippets.tex.data"))

    ls.add_snippets("tex", snippets)
    ls.add_snippets("tex", autosnippets, { type = "autosnippets" })
    ls.add_snippets("tex", require("snippets.tex.matrices"), { type = "autosnippets" })
  end,
}
