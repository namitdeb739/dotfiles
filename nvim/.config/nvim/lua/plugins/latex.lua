-- plugins/latex.lua — vimtex: Skim preview, SyncTeX, tectonic compilation

return {
  "lervag/vimtex",
  lazy = false, -- vimtex does its own filetype handling; lazy-loading breaks it
  init = function()
    -- Viewer: Skim reloads in place and ships displayline for forward search.
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_view_skim_sync = 1
    vim.g.vimtex_view_skim_activate = 0 -- refresh without stealing focus
    vim.g.vimtex_view_skim_reading_bar = 1

    -- Compiler: tectonic, no TeX distribution required.
    vim.g.vimtex_compiler_method = "tectonic"
    vim.g.vimtex_compiler_tectonic = {
      out_dir = "",
      options = { "--synctex", "--keep-logs" },
    }

    -- tectonic's logs are not latexmk-shaped, so vimtex's parser finds nothing.
    -- Read errors from :VimtexCompileOutput instead of a misleading empty list.
    vim.g.vimtex_quickfix_mode = 0

    vim.g.vimtex_mappings_prefix = "\\"
  end,
  config = function()
    -- Recompile on every write; Skim picks the new PDF up on its own.
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("vimtex_autocompile", { clear = true }),
      pattern = "*.tex",
      callback = function() vim.cmd("VimtexCompileSS") end,
    })
  end,
}
