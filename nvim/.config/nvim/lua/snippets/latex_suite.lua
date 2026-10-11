-- snippets/latex_suite.lua — build LuaSnip snippets from the LaTeX Suite export.
--
-- Template syntax carried over from Obsidian LaTeX Suite:
--   $n           tabstop n        (LaTeX Suite numbers from 0; LuaSnip from 1)
--   ${n:default} tabstop with placeholder; repeats of n become mirrors
--   [[n]]        regex capture group n (0-indexed)
--   ${VISUAL}    the visual selection

local ls = require("luasnip")
local s, i, t, f = ls.snippet, ls.insert_node, ls.text_node, ls.function_node
local rep = require("luasnip.extras").rep

local M = {}

-- Math-zone detection ------------------------------------------------------
local function in_mathzone()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

-- vimtex names the display-math zones texMathZoneY/W/V/Z and inline $..$
-- texMathZoneX. Anything unrecognised falls back to "any math zone", so a
-- display/inline-only snippet degrades to firing in both rather than never.
local function math_kind()
  local line, col = vim.fn.line("."), math.max(vim.fn.col(".") - 1, 1)
  for _, id in ipairs(vim.fn.synstack(line, col)) do
    local name = vim.fn.synIDattr(id, "name")
    if name == "texMathZoneX" then return "inline" end
    if name:match("^texMathZone[YWVZ]$") or name:match("^texMathZoneEnv") then
      return "display"
    end
  end
  return "any"
end

local CONDITION = {
  math    = in_mathzone,
  text    = function() return not in_mathzone() end,
  display = function()
    if not in_mathzone() then return false end
    local k = math_kind(); return k == "display" or k == "any"
  end,
  inline = function()
    if not in_mathzone() then return false end
    local k = math_kind(); return k == "inline" or k == "any"
  end,
}

-- A LaTeX Suite "v" snippet wraps a selection and must stay inert without one,
-- or typing a bare S in math mode expands to an empty \sqrt{}. LuaSnip parks
-- the stashed selection in this buffer variable until a snippet consumes it.
local function has_selection()
  local ok, sel = pcall(vim.api.nvim_buf_get_var, 0, "LUASNIP_SELECT_RAW")
  return ok and sel ~= nil and #sel > 0
end

-- Template -> node list ----------------------------------------------------
local function push_text(nodes, buf)
  if buf ~= "" then nodes[#nodes + 1] = t(vim.split(buf, "\n", { plain = true })) end
end

local function parse(template)
  local nodes, buf, seen, pos, n = {}, "", {}, 1, #template

  while pos <= n do
    local vis_s, vis_e = template:find("${VISUAL}", pos, true)
    local cap_s, cap_e, cap_n = template:find("%[%[(%d+)%]%]", pos)
    local ph_s, ph_e, ph_n, ph_default = template:find("%${(%d+):(.-)}", pos)
    local ts_s, ts_e, ts_n = template:find("%$(%d+)", pos)

    -- Earliest match wins; a ${n:...} always beats the $n inside it.
    local first = math.min(vis_s or math.huge, cap_s or math.huge,
                           ph_s or math.huge, ts_s or math.huge)
    if first == math.huge then break end

    push_text(nodes, buf .. template:sub(pos, first - 1))
    buf = ""

    if first == vis_s then
      nodes[#nodes + 1] = f(function(_, snip) return snip.env.LS_SELECT_RAW end, {})
      pos = vis_e + 1
    elseif first == cap_s then
      local idx = tonumber(cap_n) + 1
      nodes[#nodes + 1] = f(function(_, snip) return snip.captures[idx] or "" end, {})
      pos = cap_e + 1
    elseif first == ph_s then
      local idx = tonumber(ph_n) + 1
      if seen[idx] then nodes[#nodes + 1] = rep(idx)
      else seen[idx] = true; nodes[#nodes + 1] = i(idx, ph_default) end
      pos = ph_e + 1
    else
      local idx = tonumber(ts_n) + 1
      if seen[idx] then nodes[#nodes + 1] = rep(idx)
      else seen[idx] = true; nodes[#nodes + 1] = i(idx) end
      pos = ts_e + 1
    end
  end

  push_text(nodes, buf .. template:sub(pos))
  return nodes
end

-- Nodes without a final $0, for embedding in a snippetNode.
M.nodes = parse

-- Build --------------------------------------------------------------------
function M.build(rows)
  local snippets, autosnippets = {}, {}
  for _, r in ipairs(rows) do
    local mode_ok = CONDITION[r.mode]
    local ctx = {
      trig = r.trig,
      wordTrig = r.word or false,
      regTrig = r.regex or false,
      trigEngine = r.regex and "ecma" or "plain",
      condition = r.visual
        and function(...) return mode_ok(...) and has_selection() end
        or mode_ok,
      priority = r.prio,
    }
    local body = parse(r.repl)
    body[#body + 1] = i(0)
    local snip = s(ctx, body)
    table.insert(r.auto and autosnippets or snippets, snip)
  end
  return snippets, autosnippets
end

return M
