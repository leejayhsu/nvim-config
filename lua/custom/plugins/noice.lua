-- LazyVim-style floating command line. When you hit `:` (or `/` `?`), the
-- command line pops up in a small floating box near the top-center of the
-- screen instead of the bottom row. The autocomplete menu inside it is provided
-- by blink.cmp's cmdline mode (configured in init.lua's blink.cmp setup).
--
-- Scoped DELIBERATELY NARROW: we enable only noice's cmdline UI and leave
-- messages + notifications alone. You already route notifications through the
-- snacks.nvim notifier (see SECTION 4 in init.lua + `<leader>n`); letting noice
-- also take over `vim.notify`/messages would have the two fight over the same
-- toasts. So `messages`/`notify` stay disabled here.
--
-- WANT MORE LATER? noice can also do routed messages, an LSP progress spinner,
-- `cmp`-style signature popups, etc. Flip the relevant `enabled` flags below
-- (and reconcile with snacks). See `:h noice` / `:h noice-config`.
--
-- TO REMOVE: delete this file. The cmdline returns to the bottom row; blink's
-- cmdline autocomplete still works (that lives in init.lua, independent of noice).

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'MunifTanjim/nui.nvim', -- UI-primitive library that noice builds its windows on
  gh 'folke/noice.nvim',
}

require('noice').setup {
  -- The feature we actually want: the floating `:` prompt box.
  cmdline = {
    enabled = true,
    view = 'cmdline_popup', -- floating box; use 'cmdline' for the classic bottom row
    -- `view` above is the default for ALL cmdline kinds, so `/` and `?` search
    --  already inherit the floating box. We pin them explicitly so it's
    --  guaranteed (and obvious) rather than relying on noice's defaults.
    --  These merge into noice's built-in search formats (icon/pattern kept).
    format = {
      search_down = { view = 'cmdline_popup' },
      search_up = { view = 'cmdline_popup' },
    },
  },

  -- Let blink.cmp render the command autocomplete menu, not noice's own popupmenu.
  popupmenu = { enabled = false },

  -- Hands off — snacks.notifier owns notifications, and native handles messages.
  messages = { enabled = false },
  notify = { enabled = false },

  -- Don't override hover/signature; blink already provides signature help.
  lsp = {
    hover = { enabled = false },
    signature = { enabled = false },
  },
}
