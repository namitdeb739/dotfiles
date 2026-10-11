-- config/options.lua — vim.opt settings

local opt = vim.opt

-- Appearance
opt.termguicolors = true     -- true-colour support
opt.number = true            -- absolute line numbers
opt.relativenumber = true    -- relative numbers for easy jumps
opt.signcolumn = "yes"       -- always show sign column (avoid layout shifts)
opt.cursorline = true        -- highlight current line
opt.scrolloff = 8            -- keep 8 lines above/below cursor
opt.sidescrolloff = 8
opt.smoothscroll = true      -- scroll by screen line, not buffer line, when wrapped
opt.list = true              -- mirrors VS Code's renderWhitespace = "boundary"
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true         -- spaces, not tabs
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true         -- case-sensitive if uppercase present
opt.hlsearch = false         -- don't keep highlights after search
opt.incsearch = true

-- Splits
opt.splitright = true        -- vsplit opens to the right
opt.splitbelow = true        -- split opens below

-- Files
opt.swapfile = false
opt.backup = false
opt.undofile = true          -- persistent undo

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Misc
opt.wrap = false             -- off by default; prose filetypes re-enable it
opt.spelllang = "en_gb"      -- prose filetypes enable 'spell' in config/autocmds
opt.mouse = "a"              -- mouse support in all modes
opt.clipboard = "unnamedplus" -- use system clipboard
opt.updatetime = 250         -- faster CursorHold events (gitsigns, etc.)
opt.timeoutlen = 400         -- which-key trigger delay
opt.showmode = false         -- lualine shows mode instead
