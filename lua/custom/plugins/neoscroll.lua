-- Smooth (animated) scrolling. Replaces snacks.nvim's `scroll` module (which
-- was `scroll = { enabled = true }` in init.lua's snacks setup, but hard-skips
-- the mouse wheel). neoscroll animates both keyboard scrolls AND the mouse.
--
-- How neoscroll works: setup() maps each key in `mappings` to an animated
-- equivalent. Anything left OUT of the list keeps Vim's built-in instant
-- behavior -- that's how we keep `zz` snappy (by request).

local function gh(repo) return 'https://github.com/' .. repo end
vim.pack.add { gh 'karb94/neoscroll.nvim' }

local neoscroll = require 'neoscroll'
neoscroll.setup {
  -- neoscroll's default list is { <C-u>, <C-d>, <C-b>, <C-f>, <C-y>, <C-e>,
  -- zt, zz, zb }. We drop `zz` so it stays Vim's INSTANT recenter, and drop
  -- <C-d>/<C-u> because we map those by hand below (snappier duration).
  -- `gg`/`G` aren't in neoscroll's defaults, so they stay instant too.
  mappings = { '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zb' },
  -- Global speed knob: every scroll's duration is multiplied by this. 1/1.5
  -- means 50% faster than the base durations below (and the defaults above).
  duration_multiplier = 1 / 1.5,
}

-- Half-page scroll, animated. The cursor rides along with the viewport
-- (neoscroll's move_cursor default), so it stays put on screen as the view
-- glides -- which is what the old `<C-d>zz` / `<C-u>zz` keymaps in init.lua
-- SECTION 1 were faking with an instant recenter. Shorter than neoscroll's
-- 250ms default since these fire repeatedly when skimming a file.
vim.keymap.set('n', '<C-d>', function() neoscroll.ctrl_d { duration = 150 } end, { desc = 'Scroll down half page (smooth)' })
vim.keymap.set('n', '<C-u>', function() neoscroll.ctrl_u { duration = 150 } end, { desc = 'Scroll up half page (smooth)' })

-- Animate the mouse wheel too (snacks deliberately refused to). Each wheel
-- notch smooth-scrolls 6 lines (bump this number for bigger/smaller jumps);
-- move_cursor=false so the cursor stays where it is, matching normal wheel
-- behavior. Duration is per-notch and still scaled by duration_multiplier.
local WHEEL_LINES = 6
vim.keymap.set({ 'n', 'v', 'x' }, '<ScrollWheelUp>', function() neoscroll.scroll(-WHEEL_LINES, { move_cursor = false, duration = 80 }) end, { desc = 'Smooth scroll up (mouse)' })
vim.keymap.set({ 'n', 'v', 'x' }, '<ScrollWheelDown>', function() neoscroll.scroll(WHEEL_LINES, { move_cursor = false, duration = 80 }) end, { desc = 'Smooth scroll down (mouse)' })
