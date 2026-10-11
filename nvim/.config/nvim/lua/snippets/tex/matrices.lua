-- snippets/tex/matrices.lua — the LaTeX Suite snippets whose replacement was a
-- JavaScript function. Ported by hand; all are matrix generators driven by the
-- digits in the trigger.

local ls = require("luasnip")
local s, d, sn, i = ls.snippet, ls.dynamic_node, ls.snippet_node, ls.insert_node
local suite = require("snippets.latex_suite")

-- LaTeX Suite caps tabstops at $9 and puts the exit stop after the matrix.
local function grid(rows, cols, cell)
  local stop, out = 0, {}
  for r = 1, rows do
    local row = {}
    for c = 1, cols do
      local v = cell and cell(r, c)
      if v then
        row[#row + 1] = v
      elseif stop < 9 then
        row[#row + 1] = "$" .. stop
        stop = stop + 1
      else
        row[#row + 1] = ""
      end
    end
    out[#out + 1] = table.concat(row, " & ")
  end
  return table.concat(out, " \\\\ "), math.min(stop, 9)
end

-- Builds a snippet whose body is generated from the trigger's captures.
local function generator(trig, make)
  return s(
    { trig = trig, regTrig = true, trigEngine = "ecma", snippetType = "autosnippet",
      condition = function() return vim.fn["vimtex#syntax#in_mathzone"]() == 1 end },
    { d(1, function(_, snip) return sn(nil, suite.nodes(make(snip.captures))) end, {}), i(0) }
  )
end

local function matrix(env)
  return function(caps)
    local n = tonumber(caps[1])
    local body, exit = grid(n, n)
    return ("\\begin{%s} %s \\end{%s}$%d"):format(env, body, env, exit)
  end
end

return {
  -- pm3 / bm3 -> 3x3 pmatrix / bmatrix with a tabstop per cell
  generator("pm(\\d)", matrix("pmatrix")),
  generator("bm(\\d)", matrix("bmatrix")),

  -- rv3 / cv3 -> row / column vector
  generator("rv(\\d)", function(caps)
    local n, cols = tonumber(caps[1]), {}
    for k = 0, n - 1 do cols[#cols + 1] = "$" .. k end
    return ("\\begin{pmatrix} %s \\end{pmatrix}$%d"):format(table.concat(cols, " & "), n)
  end),
  generator("cv(\\d)", function(caps)
    local n, rows = tonumber(caps[1]), {}
    for k = 0, n - 1 do rows[#rows + 1] = "$" .. k end
    return ("\\begin{pmatrix} %s \\end{pmatrix}$%d"):format(table.concat(rows, " \\\\ "), n)
  end),

  -- iden3 -> 3x3 identity, no tabstops
  generator("iden(\\d)", function(caps)
    local n = tonumber(caps[1])
    local body = select(1, grid(n, n, function(r, c) return r == c and "1" or "0" end))
    return ("\\begin{pmatrix}\n%s\n\\end{pmatrix}"):format(body:gsub(" \\\\ ", " \\\\\n"))
  end),

  -- Diag3 -> diagonal matrix, tabstops on the diagonal only
  generator("Diag(\\d)", function(caps)
    local n, stop, out = tonumber(caps[1]), 0, {}
    for r = 1, n do
      local row = {}
      for c = 1, n do
        if r == c then row[#row + 1] = "$" .. stop; stop = stop + 1
        else row[#row + 1] = "0" end
      end
      out[#out + 1] = table.concat(row, " & ")
    end
    return ("\\begin{pmatrix} %s \\end{pmatrix}$%d"):format(table.concat(out, " \\\\ "), stop)
  end),

  -- mat_{2}x3 and m_{2}3 -> arbitrary rows x cols
  generator("mat_\\{(\\d)\\}x(\\d)", function(caps)
    local body, exit = grid(tonumber(caps[1]), tonumber(caps[2]))
    return ("\\begin{pmatrix} %s \\end{pmatrix}$%d"):format(body, exit)
  end),
  generator("m_\\{(\\d)\\}(\\d)", function(caps)
    local body, exit = grid(tonumber(caps[1]), tonumber(caps[2]))
    return ("\\begin{pmatrix} %s \\end{pmatrix}$%d"):format(body, exit)
  end),
}
