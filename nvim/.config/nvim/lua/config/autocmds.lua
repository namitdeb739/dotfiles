-- config/autocmds.lua — filetype-local behaviour and autosave

local group = vim.api.nvim_create_augroup("user_autocmds", { clear = true })

-- Prose filetypes: wrap on word boundaries, keep the indent when wrapping, and
-- spell-check. vimtex's syntax groups keep 'spell' off commands and math.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "tex", "plaintex", "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.spell = true
  end,
})

-- LaTeX: render \alpha, fractions and the $ delimiters in place. concealcursor
-- is empty so the line under the cursor always shows real source to edit.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "tex", "plaintex" },
  callback = function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = ""
  end,
})

-- Autosave .tex only. BufWritePost drives VimtexCompileSS, so this closes the
-- loop: stop typing, the PDF rebuilds and Skim reloads with no :w.
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  group = group,
  pattern = "*.tex",
  callback = function(ev)
    local buf = ev.buf
    if vim.bo[buf].modified
      and vim.bo[buf].buftype == ""
      and vim.api.nvim_buf_get_name(buf) ~= ""
    then
      vim.api.nvim_buf_call(buf, function() vim.cmd("silent! write") end)
    end
  end,
})

-- Briefly highlight yanked text.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})
