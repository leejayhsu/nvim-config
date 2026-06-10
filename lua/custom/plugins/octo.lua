-- GitHub pull requests & issues, plus a rich diff viewer, inside Neovim.
--
--  - octo.nvim     : browse/review/comment/merge PRs and issues (needs the `gh` CLI)
--  - diffview.nvim : side-by-side diffs and a file panel; octo uses it for PR reviews
--
-- Both depend on plenary.nvim. octo uses the snacks picker already configured in
-- init.lua, and nvim-web-devicons (also already installed) for file icons.

local function gh(repo) return 'https://github.com/' .. repo end

-- Shared dependency for octo and diffview.
vim.pack.add { gh 'nvim-lua/plenary.nvim' }

-- Rich diff viewer / file-history browser.
vim.pack.add { gh 'sindrets/diffview.nvim' }
require('diffview').setup {}

-- GitHub PRs & issues.
vim.pack.add { gh 'pwntester/octo.nvim' }
require('octo').setup {
  picker = 'snacks', -- match the picker chosen in init.lua
}

-- Diff the current branch against its base (main/master) — the "what's in my PR"
--  view. Diffs the WORKING TREE against the merge-base commit, so it shows every
--  change this branch introduced — committed AND uncommitted, staged AND unstaged
--  — but nothing that landed on main after you branched. (Using `main...HEAD`
--  instead would hide uncommitted WIP, since that isn't in HEAD yet.) Prefers the
--  remote ref (origin/main) so a stale local main doesn't skew the merge-base;
--  falls back to the local branch, then to plain `main`/`master` names.
local function diff_against_base()
  local function ref_exists(ref)
    return vim.fn.system { 'git', 'rev-parse', '--verify', '--quiet', ref } ~= '' and vim.v.shell_error == 0
  end
  local base
  for _, name in ipairs { 'main', 'master' } do
    for _, ref in ipairs { 'origin/' .. name, name } do
      if ref_exists(ref) then
        base = ref
        break
      end
    end
    if base then break end
  end
  if not base then
    vim.notify('diffview: no main/master branch found', vim.log.levels.WARN)
    return
  end
  local merge_base = vim.fn.system { 'git', 'merge-base', base, 'HEAD' }
  if vim.v.shell_error ~= 0 then
    vim.notify('diffview: could not find merge-base with ' .. base, vim.log.levels.WARN)
    return
  end
  merge_base = vim.trim(merge_base)
  vim.cmd('DiffviewOpen ' .. merge_base)
end
vim.keymap.set('n', '<leader>gd', diff_against_base, { desc = '[G]it: [D]iff branch vs main' })

-- Handy keymaps (octo provides the `:Octo` command for everything else).
vim.keymap.set('n', '<leader>gp', '<cmd>Octo pr list<cr>', { desc = '[G]itHub: [P]R list' })
vim.keymap.set('n', '<leader>gi', '<cmd>Octo issue list<cr>', { desc = '[G]itHub: [I]ssue list' })
vim.keymap.set('n', '<leader>gr', '<cmd>Octo review start<cr>', { desc = '[G]itHub: [R]eview PR' })

-- which-key group labels for octo's <localleader> maps. Without these, the
--  which-key popup on an octo buffer shows anonymous "+N keymaps".
--  octo's maps are BUFFER-LOCAL, so we register the group names per-buffer on
--  buffer entry rather than in init.lua's global which-key spec. The prefix
--  meanings differ by buffer kind, so each kind gets its own group set:
--
--   - PR / issue buffers      (filetype `octo`)       -> `pull_request` maps
--   - review DIFF buffers     (name `octo://…/review/…/file/…`) -> `review_diff`
--   - changed-files panel     (filetype `octo_panel`) -> `file_panel`
--
--  The diff buffers can't be matched by filetype: octo runs `filetype detect`
--  on them, so they inherit the SOURCE file's filetype (json, typescript, …).
--  We match their `octo://…/review/…` buffer name instead. Group labels mirror
--  octo's defaults in octo/config.lua.
do
  local ok_wk, wk = pcall(require, 'which-key')
  if ok_wk then
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'octo',
      desc = 'Name octo <localleader> which-key groups (PR / issue buffers)',
      callback = function(ev)
        wk.add {
          { '<localleader>a', group = 'assignee', buffer = ev.buf },
          { '<localleader>c', group = 'comment', buffer = ev.buf },
          { '<localleader>g', group = 'goto', buffer = ev.buf },
          { '<localleader>i', group = 'issue / PR state', buffer = ev.buf },
          { '<localleader>l', group = 'label', buffer = ev.buf },
          { '<localleader>p', group = 'PR / merge', buffer = ev.buf },
          { '<localleader>ps', group = 'squash & merge', buffer = ev.buf },
          { '<localleader>pr', group = 'rebase & merge', buffer = ev.buf },
          { '<localleader>r', group = 'react / reference / resolve', buffer = ev.buf },
          { '<localleader>v', group = 'review / reviewer', buffer = ev.buf },
        }
      end,
    })

    -- Review DIFF buffers (the two side-by-side diff windows). review_diff maps:
    --  c -> <localleader>ca (add review comment), s -> <localleader>sa (add
    --  review suggestion), v -> <localleader>vs / vd (submit / discard review).
    vim.api.nvim_create_autocmd('BufWinEnter', {
      pattern = 'octo://*/review/*/file/*',
      desc = 'Name octo <localleader> which-key groups (review diff buffers)',
      callback = function(ev)
        wk.add {
          { '<localleader>c', group = 'comment', buffer = ev.buf },
          { '<localleader>s', group = 'suggestion', buffer = ev.buf },
          { '<localleader>v', group = 'submit / discard review', buffer = ev.buf },
        }
      end,
    })

    -- Changed-files panel. file_panel maps only the v prefix (submit / discard).
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'octo_panel',
      desc = 'Name octo <localleader> which-key groups (changed-files panel)',
      callback = function(ev)
        wk.add {
          { '<localleader>v', group = 'submit / discard review', buffer = ev.buf },
        }
      end,
    })
  end
end

-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║ MONKEY PATCH: move the PR-review "Files changed" panel to the LEFT side.     ║
-- ║                                                                              ║
-- ║ octo hardcodes the review file panel as a BOTTOM split and exposes no        ║
-- ║ config option for its placement. The relevant code is `FilePanel:open()` in  ║
-- ║ octo/reviews/file-panel.lua, which does `sp` + `wincmd J` (bottom). We        ║
-- ║ replace that one method with a copy that does `vsp` + `wincmd H` (far left)   ║
-- ║ instead. Only the three split lines differ from upstream (marked "-- was:"). ║
-- ║                                                                              ║
-- ║ TO REMOVE: delete this entire `do ... end` block. octo reverts to the        ║
-- ║   bottom panel immediately — nothing else depends on this.                   ║
-- ║                                                                              ║
-- ║ IF IT BREAKS after an octo update: octo changed `FilePanel:open()`. Re-copy  ║
-- ║   its body from octo/reviews/file-panel.lua and re-apply the 3 swaps below,  ║
-- ║   or just delete this block to fall back to the (working) bottom panel.      ║
-- ╚════════════════════════════════════════════════════════════════════════════╝
do
  local file_panel = require 'octo.reviews.file-panel'
  local PANEL_WIDTH = 40 -- columns wide (a vertical panel needs width, not the bottom panel's row count)

  function file_panel.FilePanel:open()
    if not self:buf_loaded() then
      self:init_buffer()
    end
    if self:is_open() then
      return
    end

    self.size = PANEL_WIDTH
    vim.cmd 'vsp' -- was: vim.cmd "sp"          (vertical instead of horizontal split)
    vim.cmd 'wincmd H' -- was: vim.cmd "wincmd J"    (H = far left; J = bottom)
    vim.cmd('vertical resize ' .. self.size) -- was: vim.cmd("resize " .. self.size)
    self.winid = vim.api.nvim_get_current_win()

    vim.cmd('buffer ' .. self.bufid)

    -- winopts already sets winfixwidth = true, so the `:wincmd =` below won't
    -- squash our width — it just re-equalizes the two diff windows.
    for k, v in pairs(file_panel.FilePanel.winopts) do
      vim.api.nvim_set_option_value(k, v, { win = self.winid, scope = 'local' })
    end

    vim.cmd ':wincmd ='
  end
end
