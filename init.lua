--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- ============================================================
-- SECTION 1: FOUNDATION
-- Core Neovim settings, leaders, options, basic keymaps, basic autocmds
-- ============================================================
do
  -- Enable faster startup by caching compiled Lua modules
  vim.loader.enable()

  -- Set <space> as the leader key
  -- See `:help mapleader`
  --  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
  vim.g.mapleader = ' '
  -- localleader is kept DISTINCT from leader (backslash, Vim's default). Plugins
  --  like octo.nvim put their buffer-local maps on <localleader> (e.g. the PR
  --  review "toggle changed-files panel" is <localleader>b). If localleader were
  --  also <space>, those would collide with our global <leader> maps (<leader>b
  --  = buffer menu) and never fire. So octo's toggle is `\b`, approve is `\a`, etc.
  vim.g.maplocalleader = '\\'

  -- Set to true if you have a Nerd Font installed and selected in the terminal
  vim.g.have_nerd_font = true

  -- [[ Setting options ]]
  --  See `:help vim.o`
  -- NOTE: You can change these options as you wish!
  --  For more options, you can see `:help option-list`

  -- Make line numbers default
  vim.o.number = true
  -- Relative line numbers make vertical jumps easy (e.g. `5j`, `12k`).
  --  An autocmd below switches these off in insert mode (see [[ Basic Autocommands ]]).
  vim.o.relativenumber = true

  -- Enable mouse mode, can be useful for resizing splits for example!
  vim.o.mouse = 'a'

  -- Don't show the mode, since it's already in the status line
  vim.o.showmode = false

  -- Sync clipboard between OS and Neovim.
  --  Schedule the setting after `UiEnter` because it can increase startup-time.
  --  Remove this option if you want your OS clipboard to remain independent.
  --  See `:help 'clipboard'`
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

  -- Enable break indent
  vim.o.breakindent = true

  -- Enable undo/redo changes even after closing and reopening a file
  vim.o.undofile = true

  -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Keep signcolumn on by default
  vim.o.signcolumn = 'yes'

  -- Decrease update time
  vim.o.updatetime = 250

  -- Decrease mapped sequence wait time
  vim.o.timeoutlen = 300

  -- Configure how new splits should be opened
  vim.o.splitright = true
  vim.o.splitbelow = true

  -- Give all floating windows a rounded border. Most importantly this frames LSP
  --  hover (`K`) and signature-help floats with an opaque box, so they no longer
  --  bleed into the code behind them. See `:help 'winborder'`.
  vim.o.winborder = 'rounded'

  -- Sets how neovim will display certain whitespace characters in the editor.
  --  See `:help 'list'`
  --  and `:help 'listchars'`
  --
  --  Notice listchars is set using `vim.opt` instead of `vim.o`.
  --  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
  --   See `:help lua-options`
  --   and `:help lua-guide-options`
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

  -- Preview substitutions live, as you type!
  vim.o.inccommand = 'split'

  -- Show which line your cursor is on. Only the active window shows it (toggled
  --  by the Win/Buf autocmds below) so the cursorline doubles as an
  --  active-window indicator. Contrast is boosted in `tune_cursorline`.
  vim.o.cursorline = true

  -- Minimal number of screen lines to keep above and below the cursor.
  vim.o.scrolloff = 10

  -- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
  -- instead raise a dialog asking if you wish to save the current file(s)
  -- See `:help 'confirm'`
  vim.o.confirm = true

  -- Code folding. The fold *logic* is enabled per-buffer by treesitter (see the
  --  Treesitter section). These options control behavior: start every file with
  --  all folds open (foldlevel 99) so nothing opens collapsed, and use Neovim's
  --  syntax-highlighted fold text instead of the plain dashed line.
  --  See `:help folds`. Common keys: za toggle, zc/zo close/open, zM/zR all.
  vim.o.foldlevel = 99
  vim.o.foldlevelstart = 99
  vim.o.foldtext = ''

  -- [[ Basic Keymaps ]]
  --  See `:help vim.keymap.set()`

  -- Clear highlights on search when pressing <Esc> in normal mode
  --  See `:help hlsearch`
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  -- Exit insert mode with `jk` or `kj` so you don't have to reach for <Esc>.
  vim.keymap.set('i', 'jk', '<Esc>', { desc = 'Exit insert mode' })
  vim.keymap.set('i', 'kj', '<Esc>', { desc = 'Exit insert mode' })

  -- Jump straight to a fold level with `z1`..`z4`: e.g. `z1` collapses to just
  --  top-level items, `z2` opens one level deeper, etc. `zR` opens everything,
  --  `zM` closes everything. (This shadows the rarely-used `z{height}<CR>`.)
  for level = 1, 4 do
    vim.keymap.set('n', 'z' .. level, function() vim.wo.foldlevel = level end, { desc = 'Fold to level ' .. level })
  end

  -- Diagnostic Config & Keymaps
  --  See `:help vim.diagnostic.Opts`
  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    -- Can switch between these as you prefer
    virtual_text = true, -- Text shows up at the end of the line
    virtual_lines = false, -- Text shows up underneath the line, with virtual lines

    -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },
  }

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
  -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
  -- is not what someone will guess without a bit more experience.
  --
  -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
  -- or just use <C-\><C-n> to exit terminal mode
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- TIP: Disable arrow keys in normal mode
  -- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
  -- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
  -- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
  -- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

  -- Window management under <leader>w. <leader>w{hjkl} is the primary nav
  --  (no modifier keys); the rest add split/close/equalize verbs.
  --  See `:help wincmd` for a list of all window commands.
  vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = '[W]indow split [V]ertical' })
  vim.keymap.set('n', '<leader>ws', '<C-w>s', { desc = '[W]indow [S]plit horizontal' })
  vim.keymap.set('n', '<leader>wc', '<C-w>c', { desc = '[W]indow [C]lose' })
  vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = '[W]indow close [O]thers' })
  vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = '[W]indow equalize sizes' })
  vim.keymap.set('n', '<leader>wh', '<C-w>h', { desc = '[W]indow focus left' })
  vim.keymap.set('n', '<leader>wj', '<C-w>j', { desc = '[W]indow focus down' })
  vim.keymap.set('n', '<leader>wk', '<C-w>k', { desc = '[W]indow focus up' })
  vim.keymap.set('n', '<leader>wl', '<C-w>l', { desc = '[W]indow focus right' })
  -- Capital HJKL = focus the *farthest* window in that direction (the big count
  --  makes `wincmd` walk as far as windows exist). Mirrors the lowercase
  --  one-over focus above. Note: capital `<C-w>HJKL` normally *moves* a window;
  --  here we deliberately repurpose <leader>w{HJKL} for far-focus instead.
  vim.keymap.set('n', '<leader>wH', '999<C-w>h', { desc = '[W]indow focus far left' })
  vim.keymap.set('n', '<leader>wJ', '999<C-w>j', { desc = '[W]indow focus far down' })
  vim.keymap.set('n', '<leader>wK', '999<C-w>k', { desc = '[W]indow focus far up' })
  vim.keymap.set('n', '<leader>wL', '999<C-w>l', { desc = '[W]indow focus far right' })
  -- Quick split aliases matching the table-friendly mnemonics.
  vim.keymap.set('n', '<leader>w|', '<C-w>v', { desc = '[W]indow split vertical' })
  vim.keymap.set('n', '<leader>w-', '<C-w>s', { desc = '[W]indow split horizontal' })

  -- Half-page scroll (<C-d>/<C-u>) is handled by neoscroll in
  --  lua/custom/plugins/neoscroll.lua: it smooth-scrolls with the cursor riding
  --  along, so the viewport glides and the cursor stays put on screen -- which
  --  is what the old `<C-d>zz` recenter here was faking. (custom.plugins loads
  --  last, so any <C-d>/<C-u> map here would just be shadowed anyway.)

  -- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
  -- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
  -- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
  -- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
  -- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

  -- [[ Basic Autocommands ]]
  --  See `:help lua-guide-autocommands`

  -- Highlight when yanking (copying) text
  --  Try it with `yap` in normal mode
  --  See `:help vim.hl.on_yank()`
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })

  -- Hybrid line numbers: relative in normal mode, absolute in insert mode.
  --  Relative numbers help with vertical motions; in insert mode you usually
  --  want the plain absolute number instead. Both callbacks no-op when 'number'
  --  is off (e.g. terminals or special buffers), so they never force numbers on.
  local numbertoggle = vim.api.nvim_create_augroup('kickstart-numbertoggle', { clear = true })
  vim.api.nvim_create_autocmd('InsertEnter', {
    desc = 'Absolute line numbers in insert mode',
    group = numbertoggle,
    callback = function()
      if vim.o.number then vim.o.relativenumber = false end
    end,
  })
  vim.api.nvim_create_autocmd('InsertLeave', {
    desc = 'Relative line numbers in normal mode',
    group = numbertoggle,
    callback = function()
      if vim.o.number then vim.o.relativenumber = true end
    end,
  })

  -- Active-window cursorline. The vscode theme's default CursorLine is barely
  --  distinguishable from the background; nudge its bg further from Normal's for
  --  visible contrast, and recompute on any ColorScheme change so it survives
  --  theme reloads (e.g. the hide-comments toggle re-applies the scheme).
  local function tune_cursorline()
    local normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
    if not normal.bg then return end
    local r = math.floor(normal.bg / 65536) % 256
    local g = math.floor(normal.bg / 256) % 256
    local b = normal.bg % 256
    -- How many points (0-255 per RGB channel) to shift CursorLine's bg away
    --  from Normal's: positive = lighter (dark themes), negative = darker (light
    --  themes). Higher magnitude = more contrast / more visible line. ~12 is
    --  subtle, ~26 is strong. Tune this one number to taste.
    local delta = vim.o.background == 'dark' and 12 or -12
    local function clamp(v) return math.min(255, math.max(0, v + delta)) end
    local bg = string.format('#%02x%02x%02x', clamp(r), clamp(g), clamp(b))
    vim.api.nvim_set_hl(0, 'CursorLine', { bg = bg })
  end

  local cursorline = vim.api.nvim_create_augroup('active-cursorline', { clear = true })
  vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter' }, {
    desc = 'Show cursorline only in the active window',
    group = cursorline,
    callback = function() vim.wo.cursorline = true end,
  })
  vim.api.nvim_create_autocmd('WinLeave', {
    desc = 'Hide cursorline in inactive windows',
    group = cursorline,
    callback = function() vim.wo.cursorline = false end,
  })
  vim.api.nvim_create_autocmd('ColorScheme', {
    desc = 'Boost CursorLine contrast after any theme change',
    group = cursorline,
    callback = tune_cursorline,
  })
end

-- ============================================================
-- SECTION 2: PLUGIN MANAGER INTRO
-- vim.pack intro, build hooks
-- ============================================================
do
  -- [[ Intro to `vim.pack` ]]
  -- `vim.pack` is a new plugin manager built into Neovim,
  --  which provides a Lua interface for installing and managing plugins.
  --
  --  See `:help vim.pack`, `:help vim.pack-examples` or the
  --  excellent blog post from the creator of vim.pack and mini.nvim:
  --  https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
  --
  --  To inspect plugin state and pending updates, run
  --    :lua vim.pack.update(nil, { offline = true })
  --
  --  To update plugins, run
  --    :lua vim.pack.update()
  --
  --
  --  Throughout the rest of the config there will be examples
  --  of how to install and configure plugins using `vim.pack`.
  --
  --  In this section we set up some autocommands to run build
  --  steps for certain plugins after they are installed or updated.

  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- This autocommand runs after a plugin is installed or updated and
  --  runs the appropriate build command for that plugin if necessary.
  --
  -- See `:help vim.pack-events`
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end
    end,
  })
end

---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- SECTION 3: UI / CORE UX PLUGINS
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini modules
-- ============================================================
do
  -- [[ Installing and Configuring Plugins ]]
  --
  -- To install a plugin simply call `vim.pack.add` with its git url.
  -- This will download the default branch of the plugin, which will usually be `main` or `master`
  -- You can also have more advanced specs, which we will talk about later.
  --
  -- For most plugins its not enough to install them, you also need to call their `.setup()` to start them.
  --
  -- For example, lets say we want to install `guess-indent.nvim` - a plugin for
  -- automatically detecting and setting the indentation.
  --
  -- We first install it from https://github.com/NMAC427/guess-indent.nvim
  -- and then call its `setup()` function to start it with default settings.
  vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
  require('guess-indent').setup {}

  -- Because lua is a real programming language, you can also have some logic to your installation -
  -- like only installing a plugin if a condition is met.
  --
  -- Here we only install `nvim-web-devicons` (which adds pretty icons) if we have a Nerd Font,
  -- since otherwise the icons won't display properly.
  if vim.g.have_nerd_font then vim.pack.add { gh 'nvim-tree/nvim-web-devicons' } end

  -- Here is a more advanced configuration example that passes options to `gitsigns.nvim`
  --
  -- See `:help gitsigns` to understand what each configuration key does.
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
  require('gitsigns').setup {
    signs = {
      add = { text = '+' }, ---@diagnostic disable-line: missing-fields
      change = { text = '~' }, ---@diagnostic disable-line: missing-fields
      delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
      topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
      changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
    },
  }

  -- Useful plugin to show you pending keybinds.
  vim.pack.add { gh 'folke/which-key.nvim' }
  require('which-key').setup {
    -- Delay between pressing a key and opening which-key (milliseconds)
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },
    -- Document existing key chains
    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
      { '<leader>b', group = '[B]uffer' },
      { '<leader>w', group = '[W]indow' },
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
    },
  }

  -- [[ Colorscheme ]]
  -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command under that to load whatever the name of that colorscheme is.
  --
  -- To browse installed colorschemes, run `:lua Snacks.picker.colorschemes()`.
  vim.pack.add { gh 'Mofiqul/vscode.nvim' }
  require('vscode').setup {
    -- "dark" is the VS Code Dark+ / Dark Modern palette. Use "light" for the light variant.
    style = 'dark',
    italic_comments = false, -- Match the rest of this config: no italic comments
  }

  -- Load the colorscheme here.
  --  Switch to the light variant by setting style = 'light' above.
  vim.cmd.colorscheme 'vscode'

  -- A visual "tab bar" of open buffers across the top of the screen: file icons,
  --  a modified-indicator dot, and LSP diagnostic counts per buffer. Set up after
  --  the colorscheme so its highlights derive from the active theme.
  vim.pack.add { gh 'akinsho/bufferline.nvim' }
  -- Pull an accent color from the active theme for the active-buffer cues below.
  local function bufferline_accent()
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = 'Function' })
    if ok and hl.fg then return string.format('#%06x', hl.fg) end
    return '#4fc1ff' -- VS Code blue fallback
  end
  require('bufferline').setup {
    options = {
      numbers = 'ordinal', -- Show 1, 2, 3... on each tab so <leader>N can jump to it
      diagnostics = 'nvim_lsp', -- Show LSP error/warning counts on each buffer tab
      always_show_bufferline = true,
      show_buffer_close_icons = true,
      show_close_icon = false,
      -- A full-width colored underline under the active buffer is far easier to
      --  spot at a glance than the default thin left-edge bar.
      indicator = { style = 'underline' },
    },
    -- Terminal text is a single uniform size, so the tabs can't use a bigger font.
    --  What makes a label read as "full size" rather than thin/faint is its weight:
    --  bold every tab label. The active buffer then stands out via a brighter bold
    --  label, an accent-colored ordinal number, and the accent underline.
    highlights = {
      buffer = { bold = true, italic = false },
      buffer_visible = { bold = true, italic = false },
      buffer_selected = { bold = true, italic = false },
      numbers = { bold = true, italic = false },
      numbers_visible = { bold = true, italic = false },
      numbers_selected = { fg = bufferline_accent(), bold = true, italic = false },
      diagnostic_selected = { bold = true, italic = false },
      hint_selected = { bold = true, italic = false },
      info_selected = { bold = true, italic = false },
      warning_selected = { bold = true, italic = false },
      error_selected = { bold = true, italic = false },
    },
  }

  -- Buffer navigation & management. The tabs above update as you move/close.
  --  NOTE: <S-h>/<S-l> replace the default H/L "jump to top/bottom of screen"
  --  motions. The bracket maps ([b/]b) are an alternative that clobbers nothing.
  vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
  vim.keymap.set('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Previous buffer' })
  vim.keymap.set('n', ']b', '<cmd>bnext<cr>', { desc = 'Next buffer' })
  vim.keymap.set('n', '[b', '<cmd>bprevious<cr>', { desc = 'Previous buffer' })
  vim.keymap.set('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = '[B]uffer [D]elete' })
  vim.keymap.set('n', '<leader>bo', function() Snacks.bufdelete.other() end, { desc = '[B]uffer delete [O]thers' })
  vim.keymap.set('n', '<leader>bp', '<cmd>BufferLineTogglePin<cr>', { desc = '[B]uffer toggle [P]in' })
  vim.keymap.set('n', '<leader>bP', '<cmd>BufferLineGroupClose ungrouped<cr>', { desc = '[B]uffer close un[P]inned' })

  -- Jump directly to a buffer by its ordinal number shown on the tab.
  for i = 1, 9 do
    vim.keymap.set('n', '<leader>' .. i, '<cmd>BufferLineGoToBuffer ' .. i .. '<cr>', { desc = 'Go to buffer ' .. i })
  end
  -- Pick mode: flashes a letter on each tab; press it to jump (or close).
  vim.keymap.set('n', '<leader>bb', '<cmd>BufferLinePick<cr>', { desc = '[B]uffer pick & jump' })
  vim.keymap.set('n', '<leader>bx', '<cmd>BufferLinePickClose<cr>', { desc = '[B]uffer pick & close' })

  -- Highlight todo, notes, etc in comments
  vim.pack.add { gh 'folke/todo-comments.nvim' }
  require('todo-comments').setup { signs = false }

  -- [[ trouble.nvim ]]
  --  A pretty, navigable list for diagnostics, LSP references, quickfix, and
  --  the location list. Keymaps live under `<leader>x`. `<cmd>Trouble ... toggle`
  --  opens the panel (or closes it if already open for that mode).
  vim.pack.add { gh 'folke/trouble.nvim' }
  require('trouble').setup {}
  vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Trouble: workspace diagnostics' })
  vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Trouble: buffer diagnostics' })
  vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Trouble: location list' })
  vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Trouble: quickfix list' })
  vim.keymap.set('n', '<leader>xt', '<cmd>Trouble todo toggle<cr>', { desc = 'Trouble: todo comments' })

  -- [[ flash.nvim ]]
  --  Jump anywhere on screen by typing a couple chars then a highlighted label.
  --  `s` triggers jump (the `s` key was freed by moving mini.surround to `gs`).
  --  Works in normal, visual, and operator-pending modes, so `ys`+jump yanks
  --  to a remote location. `S` labels treesitter nodes for structural selection.
  vim.pack.add { gh 'folke/flash.nvim' }
  require('flash').setup {}
  vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash jump' })
  vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash treesitter select' })
  vim.keymap.set('o', 'r', function() require('flash').remote() end, { desc = 'Flash remote' })
  vim.keymap.set({ 'o', 'x' }, 'R', function() require('flash').treesitter_search() end, { desc = 'Flash treesitter search' })
  vim.keymap.set('c', '<c-s>', function() require('flash').toggle() end, { desc = 'Toggle flash search' })

  -- [[ grug-far.nvim ]]
  --  Project-wide find/replace with a friendly buffer UI (ripgrep-backed): type
  --  into labeled Search/Replace/Files fields instead of `:%s///` syntax, see
  --  matches live across the whole project, then apply. Keymaps under `<leader>s`
  --  (capital R/W to avoid clashing with picker resume `sr` / grep word `sw`).
  vim.pack.add { gh 'MagicDuck/grug-far.nvim' }
  require('grug-far').setup {}
  vim.keymap.set('n', '<leader>sR', function() require('grug-far').open() end, { desc = '[S]earch and [R]eplace (project)' })
  vim.keymap.set('x', '<leader>sR', function() require('grug-far').with_visual_selection() end, { desc = '[S]earch and [R]eplace (selection)' })
  vim.keymap.set('n', '<leader>sW', function() require('grug-far').open { prefills = { search = vim.fn.expand '<cword>' } } end, { desc = '[S]earch and replace [W]ord' })

  -- [[ mini.nvim ]]
  --  A collection of various small independent plugins/modules
  vim.pack.add { gh 'nvim-mini/mini.nvim' }

  -- Better Around/Inside textobjects
  --
  -- Examples:
  --  - va)  - [V]isually select [A]round [)]paren
  --  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
  --  - ci'  - [C]hange [I]nside [']quote
  require('mini.ai').setup {
    -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    n_lines = 500,
  }

  -- Add/delete/replace surroundings (brackets, quotes, etc.)
  --
  -- Mapped under the `gs` prefix (not the default `s`) so the bare `s` key is
  --  free for flash.nvim's jump motion. This matches the LazyVim convention.
  -- - gsaiw) - [G]o [S]urround [A]dd [I]nner [W]ord [)]Paren
  -- - gsd'   - [G]o [S]urround [D]elete [']quotes
  -- - gsr)'  - [G]o [S]urround [R]eplace [)] [']
  require('mini.surround').setup {
    mappings = {
      add = 'gsa',
      delete = 'gsd',
      find = 'gsf',
      find_left = 'gsF',
      highlight = 'gsh',
      replace = 'gsr',
      update_n_lines = 'gsn',
    },
  }

  -- Simple and easy statusline.
  --  You could remove this setup call if you don't like it,
  --  and try some other statusline plugin
  local statusline = require 'mini.statusline'
  -- Set `use_icons` to true if you have a Nerd Font
  statusline.setup { use_icons = vim.g.have_nerd_font }

  -- Section overrides (mini.statusline lets you replace any section's function).

  -- Filename: abbreviate the directory path to (hyphen-aware) initials, keeping
  --  the filename itself full. e.g.
  --    ~/code/my-web-app/src/services/billing/fetch-account-balance.command.ts
  --  becomes
  --    ~/c/m-w-a/s/s/b/fetch-account-balance.command.ts
  --  (`%m` = modified flag, `%r` = readonly flag — same trailing flags mini uses.)
  local function short_path()
    local path = vim.fn.expand '%:~' -- home-relative, keeps a leading ~/
    if path == '' then return '%t' end -- unnamed buffer: fall back to the tail
    local parts = vim.split(path, '/', { plain = true })
    for i = 1, #parts - 1 do -- shorten every dir; leave the filename (last part) alone
      local dir = parts[i]
      if dir ~= '' and dir ~= '~' then
        local initials = {} -- my-web-app -> m-w-a (first char of each `-` chunk)
        for chunk in dir:gmatch '[^-]+' do
          initials[#initials + 1] = chunk:sub(1, 1)
        end
        parts[i] = table.concat(initials, '-')
      end
    end
    return (table.concat(parts, '/'):gsub('%%', '%%%%')) -- escape % so the statusline doesn't expand it
  end
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_filename = function()
    if vim.bo.buftype == 'terminal' then return '%t' end
    return short_path() .. '%m%r'
  end

  -- File info: just the filetype (+ icon). Drop the default encoding/format/filesize.
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_fileinfo = function()
    local ft = vim.bo.filetype
    if ft == '' or vim.bo.buftype ~= '' then return ft end
    if vim.g.have_nerd_font then
      local ok, devicons = pcall(require, 'nvim-web-devicons')
      if ok then
        local icon = devicons.get_icon(vim.fn.expand '%:t', nil, { default = true })
        if icon then return icon .. ' ' .. ft end
      end
    end
    return ft
  end

  -- Drop the line:column readout entirely — both mini's location section and
  --  Vim's built-in ruler (which prints `1,7 All` on the command line because
  --  mini occupies the statusline).
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_location = function() return '' end
  vim.o.ruler = false

  -- A minimap on the right: a zoomed-out view of the whole file with a
  --  highlighted box for where you are, plus markers for git changes,
  --  diagnostics, and search hits. Similar to VS Code's minimap.
  local minimap = require 'mini.map'
  minimap.setup {
    integrations = {
      minimap.gen_integration.diagnostic(),
      minimap.gen_integration.gitsigns(),
      minimap.gen_integration.builtin_search(),
    },
    -- Use simple ASCII so it renders without a special font. Switch to
    --  'dot' or '3x2' (needs a capable font) for a denser, prettier map.
    symbols = { encode = minimap.gen_encode_symbols.dot '4x2' },
  }
  -- Toggle the minimap on/off. It stays off by default; open it manually here.
  vim.keymap.set('n', '<leader>tm', minimap.toggle, { desc = '[T]oggle [M]inimap' })

  -- Toggle comment visibility (<leader>tc). Blends the comment highlight groups
  --  into the Normal background so comments become invisible -- the lines stay
  --  (no reflow), they just go blank. Handy for skimming code in a heavily
  --  commented file like this one. Toggling off restores the saved colors.
  do
    local hidden = false
    -- The treesitter / LSP / legacy groups that paint comment text. We override
    --  the whole family so nothing colored leaks through the fallback chain.
    local groups = {
      'Comment',
      '@comment',
      '@comment.documentation',
      '@comment.error',
      '@comment.warning',
      '@comment.note',
      '@comment.todo',
      '@lsp.type.comment',
      'SpecialComment',
      'Todo',
    }
    local saved = {}
    local function apply()
      if hidden then
        local normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
        local bg = normal and normal.bg
        -- fg == background hides the text. With a transparent background (no
        --  Normal bg) there's no color to match, so fall back to dim grey.
        local spec = bg and { fg = bg } or { fg = '#808080' }
        for _, g in ipairs(groups) do
          saved[g] = saved[g] or vim.api.nvim_get_hl(0, { name = g })
          vim.api.nvim_set_hl(0, g, spec)
        end
      else
        for _, g in ipairs(groups) do
          if saved[g] then vim.api.nvim_set_hl(0, g, saved[g]) end
        end
        saved = {}
      end
    end
    vim.keymap.set('n', '<leader>tc', function()
      hidden = not hidden
      apply()
      vim.notify('Comments ' .. (hidden and 'hidden' or 'shown'))
    end, { desc = '[T]oggle [C]omments' })
    -- A colorscheme change repaints highlights from scratch; re-hide if active.
    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = function()
        if hidden then
          saved = {}
          apply()
        end
      end,
    })
  end

  -- ... and there is more!
  --  Check out: https://github.com/nvim-mini/mini.nvim
end

-- ============================================================
-- SECTION 4: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings
-- ============================================================
do
  -- [[ Fuzzy Finder (files, lsp, etc) ]]
  --
  -- Telescope is a fuzzy finder that comes with a lot of different things that
  -- it can fuzzy find! It's more than just a "file finder", it can search
  -- many different aspects of Neovim, your workspace, LSP, and more!
  --
  -- There are lots of other alternative pickers (like snacks.picker, or fzf-lua)
  -- so feel free to experiment and see what you like!
  --
  -- The easiest way to use Telescope, is to start by doing something like:
  --  :Telescope help_tags
  --
  -- After running this command, a window will open up and you're able to
  -- type in the prompt window. You'll see a list of `help_tags` options and
  -- a corresponding preview of the help.
  --
  -- Two important keymaps to use while in Telescope are:
  --  - Insert mode: <c-/>
  --  - Normal mode: ?
  --
  -- This opens a window that shows you all of the keymaps for the current
  -- Telescope picker. This is really useful to discover what Telescope can
  -- do as well as how to actually do it!

  -- snacks.nvim is folke's "collection of small QoL plugins". We use it here
  --  only for its `picker` module (the fuzzy finder), which is the modern
  --  alternative to Telescope. Every other snacks module stays disabled unless
  --  you explicitly enable it, so the footprint is small.
  --
  -- See https://github.com/folke/snacks.nvim and `:help snacks-picker`
  vim.pack.add { gh 'folke/snacks.nvim' }

  -- Globs the explorer never shows by default (regardless of the hidden /
  --  ignored settings). Hoisted to a local so the <a-a> show-all toggle below
  --  can restore it after temporarily clearing it.
  local explorer_exclude = {
    'node_modules',
    '.git',
    '.idea',
    '.jest',
    '.nyc_output',
    '.pytest_cache',
    'coverage',
    'dist',
    'logs',
    '.DS_Store',
    '.sentryclirc',
    '*.tsbuildinfo',
    '.husky',
    '.nvmrc',
  }

  require('snacks').setup {
    picker = {
      enabled = true,
      -- Route `vim.ui.select` (code actions, etc.) through the snacks picker,
      -- replacing what telescope-ui-select used to do.
      ui_select = true,
      sources = {
        -- Workspace symbol search returns every member by default, so a type
        -- like `Direction` gets buried under all the `direction:` fields that
        -- reference it. Restrict it to top-level *definitions* (no Field /
        -- Property) for the JS/TS family. The picker looks up this filter by the
        -- current buffer's filetype, falling back to `default` otherwise; we add
        -- filetype keys rather than overriding `default` so document-symbol
        -- search (`<leader>ss`) still shows fields/properties in its outline.
        lsp_workspace_symbols = {
          filter = (function()
            local defs = { 'Class', 'Constructor', 'Enum', 'Function', 'Interface', 'Method', 'Module', 'Namespace', 'Struct', 'Trait' }
            return {
              typescript = defs,
              typescriptreact = defs,
              javascript = defs,
              javascriptreact = defs,
              python = defs,
            }
          end)(),
        },
        -- File-tree keymaps live here (picker source config), not in the
        --  top-level `explorer` module below. Path-copy is unified with the
        --  buffer-path keymaps in SECTION 1: same `<leader>y{p,P,n}` mnemonics
        --  everywhere (relative / absolute / name). We drop snacks' default
        --  single-key `y` so there's exactly one scheme. All land in the
        --  system clipboard (`+`).
        explorer = {
          -- Show dotfiles and git-ignored files in the tree by default
          --  (toggle off live with <a-h> / <a-i> if it gets noisy).
          hidden = true,
          ignored = true,
          -- ...except these: excluded globs never show, regardless of the
          --  hidden/ignored settings or the <a-h>/<a-i> toggles. <a-a> below
          --  lifts even this filter.
          exclude = explorer_exclude,
          -- Registers an `a` title indicator (like the built-in h/i): snacks
          --  lights up the letter while `picker.opts.all` is truthy, which the
          --  toggle_show_all action below flips. (snacks also auto-generates a
          --  `toggle_all` action from this entry; it's unbound and only flips
          --  the flag, so our differently-named action is the real toggle.)
          toggles = { all = 'a' },
          actions = {
            -- <a-a>: show absolutely everything -- hidden, ignored, AND the
            --  excluded globs above. Toggling back restores the exclude list
            --  and re-asserts hidden/ignored (our defaults are both on).
            toggle_show_all = function(p)
              local o = p.opts
              o.all = not o.all
              o.exclude = o.all and {} or explorer_exclude
              o.hidden, o.ignored = true, true
              p.list:set_target()
              p:find()
            end,
            yank_rel_path = function(p, item)
              if not item then return end
              local path = Snacks.picker.util.path(item)
              local rel = vim.fs.relpath(p:cwd(), path) or vim.fn.fnamemodify(path, ':.')
              vim.fn.setreg('+', rel)
              Snacks.notify.info('Yanked: ' .. rel)
            end,
            yank_abs_path = function(_, item)
              if not item then return end
              local path = Snacks.picker.util.path(item)
              vim.fn.setreg('+', path)
              Snacks.notify.info('Yanked: ' .. path)
            end,
            yank_name = function(_, item)
              if not item then return end
              local name = vim.fn.fnamemodify(Snacks.picker.util.path(item), ':t')
              vim.fn.setreg('+', name)
              Snacks.notify.info('Yanked: ' .. name)
            end,
          },
          win = {
            input = {
              keys = {
                ['<a-a>'] = { 'toggle_show_all', mode = { 'i', 'n' } },
              },
            },
            list = {
              keys = {
                ['<a-a>'] = 'toggle_show_all',
                -- Shift-variant, matching snacks' built-in H/I toggles in the
                --  tree (handy in terminals where Option isn't sent as Alt).
                ['A'] = 'toggle_show_all',
                ['y'] = false, -- drop snacks' default single-key yank; use the leader scheme
                ['<leader>yp'] = 'yank_rel_path',
                ['<leader>yP'] = 'yank_abs_path',
                ['<leader>yn'] = 'yank_name',
              },
            },
          },
        },
      },
    },
    -- File tree / explorer, built on top of the picker above. `replace_netrw`
    --  is on by default, so opening a directory opens this instead of netrw.
    --  Path-copy keymaps (`<leader>y{p,P,n}`) are configured under
    --  `picker.sources.explorer` above.
    explorer = { enabled = true },
    -- Start screen shown when nvim launches with no file argument. Its buttons
    --  drive the snacks picker configured above. We list `sections` explicitly
    --  to omit the default `startup` footer: that section hard-requires
    --  `lazy.stats`, which doesn't exist because we bootstrap with `vim.pack`.
    dashboard = {
      enabled = true,
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        { section = 'recent_files', icon = ' ', title = 'Recent Files', padding = 1 },
        { section = 'projects', icon = ' ', title = 'Projects', padding = 1 },
      },
    },
    -- Toast-style notifications. Routes `vim.notify` through snacks, so LSP
    --  progress, plugin messages, and `:lua vim.notify(...)` all render as
    --  dismissable popups in the top-right instead of clobbering the cmdline.
    notifier = { enabled = true },
    -- Indent guides + scope highlighting. Draws a vertical line per indent
    --  level and underlines the current scope as you move through a buffer.
    indent = { enabled = true },
  }

  -- `require('snacks').setup` sets the global `Snacks`; grab the picker module
  --  so the keymaps below read cleanly.
  local picker = Snacks.picker

  -- Browse the notifier's history of past toasts (dismissed or timed out).
  vim.keymap.set('n', '<leader>n', function() Snacks.notifier.show_history() end, { desc = '[N]otification history' })

  -- See `:help snacks-picker-sources` for the full list of available pickers.
  vim.keymap.set('n', '<leader>sh', picker.help, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', picker.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', picker.files, { desc = '[S]earch [F]iles' })
  -- Like <leader>sf but includes dotfiles and git-ignored files (.env,
  --  generated code, node_modules, ...). Same effect as hitting <a-h> + <a-i>
  --  inside the files picker, just persistent.
  vim.keymap.set('n', '<leader>sF', function()
    picker.files { hidden = true, ignored = true }
  end, { desc = '[S]earch all [F]iles (+hidden/ignored)' })
  vim.keymap.set('n', '<leader>sp', picker.pickers, { desc = '[S]earch [P]ickers (select picker)' })
  -- Symbol search, kept under the `<leader>s` "search" prefix.
  --  Lowercase `s` = current document, capital `S` = whole workspace.
  vim.keymap.set('n', '<leader>ss', picker.lsp_symbols, { desc = '[S]earch document [S]ymbols' })

  -- Workspace symbol search (like VS Code's Cmd+T).
  --
  --  ┌─ WORTH-IT / MAINTENANCE NOTE ───────────────────────────────────────────┐
  --  │ This whole block exists for one convenience: searching project symbols   │
  --  │ straight from an empty buffer, without opening a file first. If you find  │
  --  │ you always have a project file open anyway, this can be deleted and the   │
  --  │ keymap reduced to: `picker.lsp_workspace_symbols`.                        │
  --  │                                                                          │
  --  │ It is NOT resource intensive: nothing runs until you press <leader>sS,    │
  --  │ and the only heavy cost (the LSP loading the project) is the same cost    │
  --  │ you'd pay opening any project file normally -- just triggered earlier.    │
  --  │ The real cost is complexity: it leans on snacks internals (one-time       │
  --  │ current-buf capture + `on_show` timing). If symbol results suddenly go    │
  --  │ empty after a snacks update, suspect the on_show backdrop swap below.     │
  --  └──────────────────────────────────────────────────────────────────────────┘
  --
  --  Two facts make a naive mapping come up empty:
  --   1. snacks queries only the LSP clients attached to the *current* buffer.
  --   2. servers like tsserver only answer workspace/symbol for a project they
  --      have actually loaded -- and they load it when a real file from the
  --      project is opened. Attaching a server to an empty [No Name] buffer
  --      loads nothing (and triggers spurious "document should be opened first"
  --      errors from the on-attach documentHighlight autocmd).
  --
  --  So when there's no symbol-capable client AND we're sitting in a throwaway
  --  buffer inside a known project, open a representative source file: that
  --  auto-starts the right server via `vim.lsp.enable` and loads the project.
  --  We then open the picker once the server attaches. NOTE: the server still
  --  needs a moment to index, so the first query may be sparse -- keep typing
  --  and results fill in. We only ever replace a throwaway buffer, never a file
  --  you're editing.
  --
  --  To support another language, add a row: `pat` matches a source file to open.
  local symbol_servers = {
    { markers = { 'tsconfig.json', 'jsconfig.json', 'package.json' }, pat = '%.[cm]?[jt]sx?$' },
    { markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile' }, pat = '%.py$' },
  }

  -- A buffer we can safely replace: the start screen, or an unnamed, unmodified,
  -- normal, single-empty-line buffer. The dashboard counts because a bare `nvim`
  -- now lands there instead of an empty [No Name] buffer; without this, priming
  -- never fires from the splash and workspace symbols comes up empty.
  local function is_throwaway(buf)
    if vim.bo[buf].filetype == 'snacks_dashboard' then
      return true
    end
    return vim.api.nvim_buf_get_name(buf) == ''
      and vim.bo[buf].buftype == ''
      and not vim.bo[buf].modified
      and vim.api.nvim_buf_line_count(buf) == 1
      and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ''
  end

  -- Open the workspace-symbol picker once a workspace/symbol-capable client is
  -- attached to `buf`, with a fallback timer in case one already is. `opened`
  -- guards against opening twice. `opts` is forwarded to the picker (e.g. an
  -- `on_close` cleanup for the primed buffer).
  local function open_symbols_picker(buf, opts)
    opts = opts or {}
    if #vim.lsp.get_clients { bufnr = buf, method = 'workspace/symbol' } > 0 then
      return picker.lsp_workspace_symbols(opts)
    end
    local opened = false
    local function open()
      if opened then return end
      opened = true
      picker.lsp_workspace_symbols(opts)
    end
    vim.api.nvim_create_autocmd('LspAttach', {
      buffer = buf,
      callback = function(ev)
        local c = vim.lsp.get_client_by_id(ev.data.client_id)
        if c and c:supports_method 'workspace/symbol' then
          vim.schedule(open)
          return true -- one-shot
        end
      end,
    })
    vim.defer_fn(open, 1000)
  end

  -- Find a source file to prime the server with. Crucially we must open a file
  -- that belongs to the project's tsconfig/program -- opening a root-level config
  -- file (jest.config.ts, etc.) makes tsserver build an "inferred project" with
  -- only that file, so workspace/symbol returns almost nothing. So we prefer
  -- files under conventional source dirs and skip config/declaration/build/vendor.
  local source_dirs = { 'src', 'app', 'lib', 'source', 'packages' }
  local function find_source(root, pat)
    local function pred(name, path)
      if path:match 'node_modules' or path:match '%.git' or path:match '/dist' or path:match '/build' then
        return false
      end
      if name:match '%.config%.' or name:match '%.d%.ts$' then
        return false
      end
      return name:match(pat) ~= nil
    end
    -- Prefer a real source directory so we land inside the configured project.
    for _, d in ipairs(source_dirs) do
      local dir = root .. '/' .. d
      if vim.uv.fs_stat(dir) then
        local f = vim.fs.find(pred, { path = dir, type = 'file', limit = 1 })[1]
        if f then return f end
      end
    end
    return vim.fs.find(pred, { path = root, type = 'file', limit = 1 })[1]
  end

  local function workspace_symbols()
    local buf = vim.api.nvim_get_current_buf()
    if #vim.lsp.get_clients { bufnr = buf, method = 'workspace/symbol' } == 0 and is_throwaway(buf) then
      for _, entry in ipairs(symbol_servers) do
        local root = vim.fs.root(buf, entry.markers)
        local file = root and find_source(root, entry.pat)
        if file then
          -- The primed file MUST stay loaded while the picker is open: tsserver
          -- only keeps the project loaded for an open file, and snacks keeps
          -- querying the client attached to this buffer. So we can't close it
          -- mid-search -- but we can keep it off screen. snacks captures its
          -- query target buffer once at creation, so:
          --   * on_show: after that capture, swap the backdrop window to a fresh
          --     empty buffer -- the file is never visible, queries still use it.
          --   * on_close: wipe the primed buffer (and the throwaway backdrop)
          --     unless you actually navigated into it.
          -- It's also `buflisted = false` so bufferline never shows it.
          vim.cmd.edit(vim.fn.fnameescape(file))
          local primed = vim.api.nvim_get_current_buf()
          vim.bo[primed].buflisted = false
          local backdrop ---@type number? empty buffer shown instead of the file
          local opts = {
            on_show = function(p)
              if p.main and vim.api.nvim_win_is_valid(p.main) then
                vim.api.nvim_win_call(p.main, function() vim.cmd 'enew' end)
                backdrop = vim.api.nvim_win_get_buf(p.main)
              end
            end,
            on_close = function()
              vim.schedule(function()
                -- If you jumped to a symbol inside the primed file, keep it and
                -- let bufferline show it; otherwise drop it.
                if vim.api.nvim_buf_is_valid(primed) then
                  if #vim.fn.win_findbuf(primed) > 0 then
                    vim.bo[primed].buflisted = true
                  else
                    pcall(vim.api.nvim_buf_delete, primed, { force = true })
                  end
                end
                -- Drop the throwaway backdrop unless it's the buffer you're now in.
                if backdrop and vim.api.nvim_buf_is_valid(backdrop) and #vim.fn.win_findbuf(backdrop) == 0 then
                  pcall(vim.api.nvim_buf_delete, backdrop, { force = true })
                end
              end)
            end,
          }
          return open_symbols_picker(primed, opts)
        end
      end
    end
    picker.lsp_workspace_symbols()
  end
  vim.keymap.set('n', '<leader>sS', workspace_symbols, { desc = '[S]earch workspace [S]ymbols' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', picker.grep_word, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', picker.grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', picker.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', picker.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', picker.recent, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader>sc', picker.commands, { desc = '[S]earch [C]ommands' })
  vim.keymap.set('n', '<leader><leader>', picker.buffers, { desc = '[ ] Find existing buffers' })

  -- Toggle the file explorer (a snacks.picker-based file tree sidebar).
  vim.keymap.set('n', '<leader>e', function() Snacks.explorer() end, { desc = 'File [E]xplorer' })

  -- [Y]ank the current buffer's path to the system clipboard (`+`, synced via
  --  `clipboard=unnamedplus`). Lowercase `p` = relative to cwd, uppercase `P` =
  --  absolute, `n` = filename only. The file tree uses the same `<leader>y*`
  --  scheme (see `picker.sources.explorer`).
  local function yank_buf_path(mod)
    local path = vim.fn.expand('%' .. mod)
    if path == '' then return vim.notify('No file in current buffer', vim.log.levels.WARN) end
    vim.fn.setreg('+', path)
    vim.notify('Yanked: ' .. path)
  end
  vim.keymap.set('n', '<leader>yp', function() yank_buf_path ':.' end, { desc = '[Y]ank relative [P]ath' })
  vim.keymap.set('n', '<leader>yP', function() yank_buf_path ':p' end, { desc = '[Y]ank absolute [P]ath' })
  vim.keymap.set('n', '<leader>yn', function() yank_buf_path ':t' end, { desc = '[Y]ank file[N]ame' })

  -- Git helpers from snacks.nvim. These are "on-demand" modules: they work
  --  whenever called, so they only need keymaps (no entry in the setup block).
  vim.keymap.set('n', '<leader>gg', function() Snacks.lazygit() end, { desc = '[G]it: Lazy[g]it' })
  vim.keymap.set('n', '<leader>gb', function() Snacks.git.blame_line() end, { desc = '[G]it: [B]lame line' })
  -- In visual mode this links to the selected line range on the remote.
  vim.keymap.set({ 'n', 'v' }, '<leader>gB', function() Snacks.gitbrowse() end, { desc = '[G]it: open in [B]rowser' })

  -- Add picker-based LSP mappings when an LSP attaches to a buffer.
  -- If you later switch picker plugins, this is where to update these mappings.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('snacks-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf

      -- Find references for the word under your cursor.
      vim.keymap.set('n', 'grr', picker.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

      -- Jump to the implementation of the word under your cursor.
      -- Useful when your language has ways of declaring types without an actual implementation.
      vim.keymap.set('n', 'gri', picker.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

      -- Jump to the definition of the word under your cursor.
      -- This is where a variable was first declared, or where a function is defined, etc.
      -- To jump back, press <C-t>.
      vim.keymap.set('n', 'grd', picker.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

      -- Fuzzy find all the symbols in your current document.
      -- Symbols are things like variables, functions, types, etc.
      vim.keymap.set('n', 'gO', picker.lsp_symbols, { buffer = buf, desc = 'Open Document Symbols' })

      -- Fuzzy find all the symbols in your current workspace.
      -- Similar to document symbols, except searches over your entire project.
      vim.keymap.set('n', 'gW', picker.lsp_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

      -- Jump to the type of the word under your cursor.
      -- Useful when you're not sure what type a variable is and you want to see
      -- the definition of its *type*, not where it was *defined*.
      vim.keymap.set('n', 'grt', picker.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
    end,
  })

  -- Fuzzily search within the current buffer's lines.
  vim.keymap.set('n', '<leader>/', function()
    picker.lines()
  end, { desc = '[/] Fuzzily search in current buffer' })

  -- Live grep, but restricted to the files you currently have open.
  --  See `:help snacks-picker-sources` for the available picker sources.
  vim.keymap.set('n', '<leader>s/', function()
    picker.grep_buffers()
  end, { desc = '[S]earch [/] in Open Files' })

  -- Shortcut for searching your Neovim configuration files
  vim.keymap.set('n', '<leader>sn', function()
    picker.files { cwd = vim.fn.stdpath 'config' }
  end, { desc = '[S]earch [N]eovim files' })
end

-- ============================================================
-- SECTION 5: LSP
-- LSP keymaps, server configuration, Mason tools installations
-- ============================================================
do
  -- [[ LSP Configuration ]]
  -- Brief aside: **What is LSP?**
  --
  -- LSP is an initialism you've probably heard, but might not understand what it is.
  --
  -- LSP stands for Language Server Protocol. It's a protocol that helps editors
  -- and language tooling communicate in a standardized fashion.
  --
  -- In general, you have a "server" which is some tool built to understand a particular
  -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
  -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
  -- processes that communicate with some "client" - in this case, Neovim!
  --
  -- LSP provides Neovim with features like:
  --  - Go to definition
  --  - Find references
  --  - Autocompletion
  --  - Symbol Search
  --  - and more!
  --
  -- Thus, Language Servers are external tools that must be installed separately from
  -- Neovim. This is where `mason` and related plugins come into play.
  --
  -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
  -- and elegantly composed help section, `:help lsp-vs-treesitter`

  -- Useful status updates for LSP.
  vim.pack.add { gh 'j-hui/fidget.nvim' }
  require('fidget').setup {}

  --  This function gets run when an LSP attaches to a particular buffer.
  --    That is to say, every time a new file is opened that is associated with
  --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
  --    function will be executed to configure the current buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      -- NOTE: Remember that Lua is a real programming language, and as such it is possible
      -- to define small helper and utility functions so you don't have to repeat yourself.
      --
      -- In this case, we create a function that lets us more easily define mappings specific
      -- for LSP related items. It sets the mode, buffer and description for us each time.
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- Rename the variable under your cursor.
      --  Most Language Servers support renaming across files, etc.
      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

      -- Execute a code action, usually your cursor needs to be on top of an error
      -- or a suggestion from your LSP for this to activate.
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

      -- WARN: This is not Goto Definition, this is Goto Declaration.
      --  For example, in C this would take you to the header.
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- Signature help: show the function signature + which parameter you're on,
      --  for the call your cursor sits inside. Complements `K` (hover), which
      --  reads the symbol under the cursor. (<C-k> already toggles this in insert
      --  mode via blink.cmp; this is the normal-mode equivalent.)
      map('<leader>k', vim.lsp.buf.signature_help, 'Signature help')

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      --    See `:help CursorHold` for information about when this is executed
      --
      -- When you move your cursor, the highlights will be cleared (the second autocommand).
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- The following code creates a keymap to toggle inlay hints in your
      -- code, if the language server you are using supports them
      --
      -- This may be unwanted, since they displace some of your code
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --  See `:help lsp-config` for information about keys and how to configure
  ---@type table<string, vim.lsp.Config>
  local servers = {
    -- clangd = {},
    -- gopls = {},
    -- rust_analyzer = {},
    --
    -- Some languages (like typescript) have entire language plugins that can be useful:
    --    https://github.com/pmizio/typescript-tools.nvim
    --
    -- But for many setups, the LSP (`ts_ls`) will work just fine
    ts_ls = {},

    -- Python: ty, Astral's type checker / language server.
    ty = {},

    -- Elixir / Phoenix
    elixirls = {},

    stylua = {}, -- Used to format Lua code

    -- Special Lua Config, as recommended by neovim help docs
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          workspace = {
            checkThirdParty = false,
            -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
            --  See https://github.com/neovim/nvim-lspconfig/issues/3189
            library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
              '${3rd}/luv/library',
              '${3rd}/busted/library',
            }),
          },
        })
      end,
      ---@type lspconfig.settings.lua_ls
      settings = {
        Lua = {
          format = { enable = false }, -- Disable formatting (formatting is done by stylua)
        },
      },
    },
  }

  vim.pack.add {
    gh 'neovim/nvim-lspconfig',
    gh 'mason-org/mason.nvim',
    gh 'mason-org/mason-lspconfig.nvim',
    gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  }

  -- Automatically install LSPs and related tools to stdpath for Neovim
  require('mason').setup {}

  -- Ensure the servers and tools above are installed
  --
  -- To check the current status of installed tools and/or manually install
  -- other tools, you can run
  --    :Mason
  --
  -- You can press `g?` for help in this menu.
  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, {
    -- You can add other tools here that you want Mason to install
  })

  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

-- ============================================================
-- SECTION 6: FORMATTING
-- conform.nvim setup and keymap
-- ============================================================
do
  -- [[ Formatting ]]
  vim.pack.add { gh 'stevearc/conform.nvim' }

  -- Resolve an executable from the nearest node_modules/.bin, walking up from
  -- `dir` (so monorepos / hoisted installs / non-root cwd all work). Falls back
  -- to the bare name on PATH if no local install is found.
  local function node_modules_bin(name, dir)
    for _, nm in ipairs(vim.fs.find('node_modules', { path = dir, upward = true, type = 'directory', limit = math.huge })) do
      local bin = nm .. '/.bin/' .. name
      if vim.uv.fs_stat(bin) then return bin end
    end
    return name
  end

  -- Resolve a Python tool from the nearest project virtualenv's bin, walking up
  -- from `dir`. Falls back to the bare name on PATH (e.g. a global ruff install).
  local function venv_bin(name, dir)
    for _, marker in ipairs { '.venv', 'venv' } do
      for _, venv in ipairs(vim.fs.find(marker, { path = dir, upward = true, type = 'directory', limit = math.huge })) do
        local bin = venv .. '/bin/' .. name
        if vim.uv.fs_stat(bin) then return bin end
      end
    end
    return name
  end

  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- You can specify filetypes to autoformat on save here:
      local enabled_filetypes = {
        -- lua = true,
        python = true,
        javascript = true,
        javascriptreact = true,
        typescript = true,
        typescriptreact = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then
        return { timeout_ms = 500 }
      else
        return nil
      end
    end,
    default_format_opts = {
      lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
    },
    -- You can also specify external formatters in here.
    formatters_by_ft = {
      -- rust = { 'rustfmt' },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { "prettierd", "prettier", stop_after_first = true },

      -- oxfmt (Oxc formatter) for TypeScript / JavaScript.
      javascript = { 'oxfmt' },
      javascriptreact = { 'oxfmt' },
      typescript = { 'oxfmt' },
      typescriptreact = { 'oxfmt' },

      -- ruff for Python: sort imports, then format (runs sequentially).
      python = { 'ruff_organize_imports', 'ruff_format' },
    },
    -- Custom formatter definition for oxfmt, resolved from the project's
    -- node_modules/.bin (see node_modules_bin above). oxfmt reads the buffer on
    -- stdin and uses --stdin-filepath to infer the parser from the file's name.
    formatters = {
      oxfmt = {
        command = function(_, ctx) return node_modules_bin('oxfmt', ctx.dirname) end,
        args = { '--stdin-filepath=$FILENAME' },
        stdin = true,
      },
      -- Override only the command of conform's built-in ruff formatters so they
      -- resolve from the project venv; their built-in args/stdin are preserved.
      ruff_format = {
        command = function(_, ctx) return venv_bin('ruff', ctx.dirname) end,
      },
      ruff_organize_imports = {
        command = function(_, ctx) return venv_bin('ruff', ctx.dirname) end,
      },
    },
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
end

-- ============================================================
-- SECTION 7: AUTOCOMPLETE & SNIPPETS
-- blink.cmp and luasnip setup
-- ============================================================
do
  -- [[ Snippet Engine ]]

  -- NOTE: You can also specify plugin using a version range for its git tag.
  --  See `:help vim.version.range()` for more info
  vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
  require('luasnip').setup {}

  -- `friendly-snippets` contains a variety of premade snippets.
  --    See the README about individual language/framework/plugin snippets:
  --    https://github.com/rafamadriz/friendly-snippets
  --
  -- vim.pack.add { gh 'rafamadriz/friendly-snippets' }
  -- require('luasnip.loaders.from_vscode').lazy_load()

  -- [[ Autocomplete Engine ]]
  vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
  require('blink.cmp').setup {
    keymap = {
      -- The 'super-tab' preset: <Tab> accepts the highlighted completion (and
      --  if nothing is highlighted yet, it selects the top item and accepts it).
      --  When a snippet is active instead, <Tab> jumps to the next placeholder
      --  and <S-Tab> jumps back.
      --
      -- Other presets: 'default' (<C-y> to accept), 'enter' (<CR> to accept),
      --  'none' (no mappings). See `:help blink-cmp-config-keymap`.
      --
      -- All presets also map:
      -- <c-space>: open menu / toggle docs
      -- <c-n>/<c-p> or <up>/<down>: select next/previous item
      -- <c-e>: hide menu
      -- <c-k>: toggle signature help
      preset = 'super-tab',

      -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
      --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono',
    },

    completion = {
      -- By default, you may press `<c-space>` to show the documentation.
      -- Optionally, set `auto_show = true` to show the documentation after a delay.
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },

    snippets = { preset = 'luasnip' },

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    --
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    --
    -- See `:help blink-cmp-config-fuzzy` for more information
    fuzzy = { implementation = 'lua' },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },

    -- Command-line completion: the popup menu of matching `:` commands, paths,
    --  etc. as you type (the "autocomplete for system commands" bit). blink
    --  ships a `cmdline` source by default, so we just turn the mode on.
    --  auto_show only for `:` ex-commands -- a menu popping up during `/`?`
    --  search is more annoying than useful.
    cmdline = {
      enabled = true,
      keymap = { preset = 'cmdline' }, -- <Tab> show/next, <C-n>/<C-p> cycle, <CR> accept+run
      completion = {
        menu = { auto_show = function() return vim.fn.getcmdtype() == ':' end },
      },
    },
  }
end

-- ============================================================
-- SECTION 8: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation
-- ============================================================
do
  -- [[ Configure Treesitter ]]
  --  Used to highlight, edit, and navigate code
  --
  --  See `:help nvim-treesitter-intro`

  -- NOTE: You can also specify a branch or a specific commit
  vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

  -- Ensure basic parsers are installed
  local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
  require('nvim-treesitter').install(parsers)

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    -- Check if a parser exists and load it
    if not vim.treesitter.language.add(language) then return end
    -- Enable syntax highlighting and other treesitter features
    vim.treesitter.start(buf, language)

    -- Enable treesitter based folds (structural folds from the syntax tree).
    -- For more info on folds see `:help folds`
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo.foldmethod = 'expr'

    -- Check if treesitter indentation is available for this language, and if so enable it
    -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
    local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

    -- Enable treesitter based indentation
    if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end

  local available_parsers = require('nvim-treesitter').get_available()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

      if vim.tbl_contains(installed_parsers, language) then
        -- Enable the parser if it is already installed
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
        require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
      else
        -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
        treesitter_try_attach(buf, language)
      end
    end,
  })
end

-- ============================================================
-- SECTION 9: CUSTOM PLUGIN LOADER
-- ============================================================
do
  -- Self-contained plugins live in their own files under `lua/custom/plugins/*.lua`
  -- (e.g. octo.lua). This requires `lua/custom/plugins/init.lua`, which loops over
  -- every file in that dir and loads it — drop a new file in and it auto-loads.
  -- See "Where plugins live" in CLAUDE.md.
  require 'custom.plugins'
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
