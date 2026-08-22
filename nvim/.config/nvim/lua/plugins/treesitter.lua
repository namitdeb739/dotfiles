-- plugins/treesitter.lua — syntax highlighting and indentation

-- nvim-treesitter's `main` branch (the default since the rewrite, and the only
-- one that supports Neovim 0.11+) removed `nvim-treesitter.configs`. There is
-- no `ensure_installed`/`highlight`/`indent` table any more: parsers are
-- installed imperatively, and highlighting is started per-buffer.

local parsers = {
  "bash",
  "c",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,   -- the FileType autocmd below must be registered before any buffer loads
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

    -- Install only what is missing; install() is async and re-installing on
    -- every launch would rebuild parsers each time.
    local installed = require("nvim-treesitter").get_installed()
    local missing = vim.tbl_filter(function(p)
      return not vim.tbl_contains(installed, p)
    end, parsers)
    if #missing > 0 then
      require("nvim-treesitter").install(missing)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
      callback = function(ev)
        -- Not every filetype has a parser installed; failing to start is fine.
        if not pcall(vim.treesitter.start, ev.buf) then
          return
        end
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
