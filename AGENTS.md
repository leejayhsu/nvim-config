# Neovim config

Personal Neovim config, derived from kickstart.nvim. Most of it lives in a single
`init.lua`, organized into numbered sections (each wrapped in a `do ... end`
block to scope locals); a few self-contained plugins live in their own files under
`lua/custom/plugins/` (see "Where plugins live" below):

- **SECTION 1: FOUNDATION** — options, leaders (`<space>`), basic keymaps/autocmds
- **SECTION 2/3** — plugins via `vim.pack` (native package manager), UI (bufferline)
- **SECTION 4: PICKER** — `snacks.nvim` picker (fuzzy finder, replaces Telescope)
- **SECTION 5: LSP** — `vim.lsp.config`/`vim.lsp.enable` (native LSP), Mason, servers
- **SECTION 6: FORMATTING** — `conform.nvim`

Conventions:
- Plugins loaded with `vim.pack.add { gh '<owner>/<repo>' }` (no lazy.nvim/packer).
- LSP uses Neovim 0.11+ native API: register with `vim.lsp.config(name, cfg)` then
  `vim.lsp.enable(name)`. Servers auto-start on matching `FileType`.
- Servers: `ts_ls` (JS/TS), `ty` (Python, Astral), `lua_ls`. Formatting via stylua/conform.
- Search keymaps under `<leader>s`; buffers under `<leader>b`; git under `<leader>g`.

After editing `init.lua`, sanity-check it parses with:
`nvim --headless -c "lua assert(loadfile('init.lua'))" -c "qa"`

## Where plugins live

Two patterns, both valid — when adding a plugin, pick by size:

1. **Inline in `init.lua`** (the majority) — a `vim.pack.add { gh '...' }` plus
   `setup`/keymaps inside the relevant numbered `do ... end` section. Use this for
   plugins that belong to an existing section (picker, LSP, formatting, UI).
2. **A standalone file in `lua/custom/plugins/*.lua`** — for a self-contained
   feature with its own deps. Each file imperatively calls `vim.pack.add` + `setup`
   itself (it is NOT a lazy.nvim spec — we don't `return` a table). Currently:
   `octo.lua` (octo.nvim + diffview.nvim + plenary, for GitHub PR review).

The directory `lua/custom/plugins/` is the kickstart convention, but the loader is
adapted for `vim.pack`: `init.lua`'s last line `require 'custom.plugins'` runs
`lua/custom/plugins/init.lua`, which loops over every `*.lua` in the dir (except
`init.lua`) and `require`s it. So **dropping a new file in that dir auto-loads it**
— no registration needed.

When hunting for a plugin's config, grep BOTH `init.lua` and
`lua/custom/plugins/`. `lua/kickstart/plugins/*.lua` and `lua/kickstart/health.lua`
are dormant leftovers from the kickstart base — every `require 'kickstart.plugins.*'`
is commented out, so nothing there loads. Ignore them (or delete).

## Workspace symbol search (`<leader>sS`, VS Code Cmd+T equivalent)

Lives in SECTION 4 (the snacks picker block): `workspace_symbols` /
`open_symbols_picker` / `find_source` helpers, plus a kind-filter in
`snacks.setup` under `picker.sources.lsp_workspace_symbols.filter`.

`<leader>ss` = document symbols, `<leader>sS` = workspace symbols, `<leader>sp` =
picker-of-pickers.

**Why it's more than a one-liner** (verified against the installed snacks source):

1. snacks queries `workspace/symbol` only on the LSP client attached to the
   **current buffer**, captured **once** at picker creation as a buffer number.
   There's no public option to redirect it.
2. tsserver/`ts_ls` only answers workspace/symbol for a project it has **loaded**,
   which happens when a real source file is opened. An empty `[No Name]` buffer
   loads nothing → `0/0` results + spurious `documentHighlight` errors.
3. The opened file must be **inside the tsconfig program** (e.g. a project whose
   `include: ["src/**/*.ts"]`). Opening an excluded root config file like
   `jest.config.ts` gives an "inferred project" with almost no symbols — so
   `find_source` prefers `src/`/`app/`/`lib/` and skips config/`.d.ts`/vendor dirs.

**Flow:** if the current buffer has no symbol client and is a throwaway buffer in a
known project → `:edit` a representative source file (primes the project) → open
the picker once the server attaches (1s fallback) → `on_show` swaps the backdrop
window to an empty buffer so the file is never visible → `on_close` wipes the
primed + backdrop buffers (unless you navigated into the primed file). Primed
buffer is `buflisted = false` so bufferline ignores it.

**Kind filter:** definitions only (drops `Field`/`Property`), set per-filetype
(typescript/tsx/javascript/jsx/python) rather than overriding `default`, so
`<leader>ss` document outlines still show fields.

**Caveats / where to look if it breaks:**
- `ty` (Python) may not implement `workspace/symbol`. If Python comes up empty,
  switch the Python row in `symbol_servers` to `basedpyright`/`pyright` (add it to
  the LSP `servers` table first).
- The hide-the-buffer mechanism leans on snacks internals (`on_show` timing +
  one-time current-buf capture). If results suddenly go empty after a snacks
  update, suspect the `on_show` backdrop swap.
- **Cost:** not resource intensive — nothing runs until `<leader>sS`, and the only
  heavy cost (LSP loading the project) is the same as opening any project file. The
  real cost is config complexity; it can be deleted and reduced to plain
  `picker.lsp_workspace_symbols` if the open-a-file-first habit is acceptable.
