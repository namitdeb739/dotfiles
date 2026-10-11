-- config/prose.lua — a non-modal drafting mode: stay in insert, select with
-- shift+arrows, undo with <C-z>. Toggle per buffer with <leader>P or :Prose.
-- Normal-mode nvim is untouched while it is off.

-- keymodel/selectmode/whichwrap are global; save them when the first prose
-- buffer opens and restore when the last one closes.
local saved, active = nil, 0

-- <C-i> is <Tab> on a terminal and <C-m> is <CR>, so neither can be bound here.
local maps = {
  { "i", "<C-z>", "<Cmd>undo<CR>", "Undo" },
  { "i", "<C-y>", "<Cmd>redo<CR>", "Redo" },
  { "i", "<C-s>", "<Cmd>write<CR>", "Save" },
  { "i", "<C-a>", "<Esc>gg0vG$<C-g>", "Select all" },
  -- Move by screen line, not buffer line: a wrapped paragraph is one line to
  -- the buffer but several to the eye.
  { "i", "<Up>", "<Cmd>normal! gk<CR>", "Up one screen line" },
  { "i", "<Down>", "<Cmd>normal! gj<CR>", "Down one screen line" },
  { "i", "<Home>", "<Cmd>normal! g0<CR>", "Start of screen line" },
  { "i", "<End>", "<Cmd>normal! g$<CR>", "End of screen line" },
  -- Shift+arrows enter Select mode via keymodel, where a printable key replaces
  -- the selection. LuaSnip stores selections from visual mode, so bridge across.
  { "s", "<Tab>", "<C-g><Tab>", "Stash selection for a visual snippet" },
}

local function enable(buf)
  if vim.b[buf].prose then
    return
  end
  if active == 0 then
    saved = {
      keymodel = vim.o.keymodel,
      selectmode = vim.o.selectmode,
      whichwrap = vim.o.whichwrap,
    }
    vim.o.keymodel = "startsel,stopsel"
    vim.o.selectmode = "key,mouse"
    vim.o.whichwrap = "b,s,<,>,[,]" -- arrows cross line boundaries
  end
  active = active + 1

  vim.bo[buf].textwidth = 0
  vim.wo.linebreak = true -- wrap at words, not mid-word

  for _, m in ipairs(maps) do
    vim.keymap.set(m[1], m[2], m[3], { buffer = buf, desc = "Prose: " .. m[4] })
  end

  vim.b[buf].prose = true
  vim.cmd.startinsert()
end

local function disable(buf)
  if not vim.b[buf].prose then
    return
  end
  for _, m in ipairs(maps) do
    pcall(vim.keymap.del, m[1], m[2], { buffer = buf })
  end

  active = active - 1
  if active == 0 and saved then
    vim.o.keymodel, vim.o.selectmode, vim.o.whichwrap =
      saved.keymodel, saved.selectmode, saved.whichwrap
    saved = nil
  end

  vim.b[buf].prose = nil
  vim.cmd.stopinsert()
end

local function toggle()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].prose then
    disable(buf)
    vim.notify("Prose mode off")
  else
    enable(buf)
    vim.notify("Prose mode on")
  end
end

-- A buffer unloaded while in prose mode would otherwise leak its count and
-- strand the global options.
vim.api.nvim_create_autocmd("BufUnload", {
  group = vim.api.nvim_create_augroup("prose_mode", { clear = true }),
  callback = function(ev)
    if vim.b[ev.buf] and vim.b[ev.buf].prose then
      disable(ev.buf)
    end
  end,
})

vim.api.nvim_create_user_command("Prose", toggle, { desc = "Toggle prose mode" })
vim.keymap.set("n", "<leader>P", toggle, { desc = "Toggle prose mode" })
