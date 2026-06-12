# General guidelines
- always use conventional commit naming for pr titles and commit messages

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

## Code navigation, selection & manipulation toolkit

**Read this before advising on how to move around, select, or edit code.** This
config layers several plugins on top of vanilla Vim motions — prefer these over
generic `:s///`, manual `f`/`t` hunting, or visual-mode line-counting. Everything
below is verified against `init.lua` + `lua/custom/plugins/`; keys are accurate as
configured (not plugin defaults). Leader is `<space>`, localleader is `\`.

### Jumping around the screen / file (motions)

| Key | What | Notes |
|-----|------|-------|
| `s` + 2 chars + label | **flash.nvim** jump anywhere on screen | works in normal **and** operator-pending/visual — `ds`, `ys`, `cs` jump-then-act on a remote spot |
| `S` | flash **treesitter** select | labels syntax nodes for structural selection |
| `r` (op-pending) | flash **remote** | operate on a remote textobject without moving, e.g. `yr` |
| `R` (op/visual) | flash treesitter search | |
| `5j` / `12k` | relative-number jumps | `relativenumber` is on — count off the gutter |
| `<C-d>`/`<C-u>` | smooth half-page scroll (**neoscroll**) | `<C-f>`/`<C-b>` full page; `zz` stays instant |
| `<C-o>`/`<C-i>` | jumplist back/forward | built-in |
| `<C-t>` | pop back after a definition jump | built-in tagstack |
| `z1`..`z4` | fold to level N | `zR` open all, `zM` close all, `za` toggle (treesitter folds) |
| `[d`/`]d` | prev/next diagnostic | auto-opens the float on landing |

Reach for `s` (flash) instead of repeated `w`/`f`/`/` when the target is visible —
it's the single biggest "expert" win here.

### Selecting (text objects)

- **mini.ai** extends `a`/`i`: `va)`, `ci'`, `ci(`, `dat`, `yiiq` ([y]ank [i]nside
  [i]+1 [q]uote), `vi{`, etc. `n_lines = 500` so it searches across lines.
- `aa` / `ii` = the **next** around/inside object (mini.ai's `around_next`/`inside_next`),
  e.g. `ciaa)` changes inside the next parens.
- `S` (flash treesitter) for structural/AST-aware selection when bracket-matching
  isn't enough.

### Manipulating code

| Key | Action | Plugin |
|-----|--------|--------|
| `gsa{motion}{char}` | **add** surround, e.g. `gsaiw)`, `gsa$"` | mini.surround |
| `gsd{char}` | **delete** surround, e.g. `gsd'` | mini.surround |
| `gsr{old}{new}` | **replace** surround, e.g. `gsr)'` | mini.surround |
| `gsf`/`gsF` | find surround right/left | mini.surround |
| `gcc` / `gc{motion}` | toggle comment (line / motion), `gc` in visual | built-in (Neovim ≥0.10) |
| `<leader>f` | format buffer (n/visual) | conform.nvim (also format-on-save for py/js/ts) |
| `grn` | LSP rename (across files) | native LSP |
| `gra` | LSP code action (n/visual) | native LSP |

mini.surround lives on `gs*`, **not** the default `s*` — `s` was freed for flash.

### Find / replace across the project

- `<leader>sR` — **grug-far** project-wide find/replace buffer (ripgrep-backed,
  live preview). Visual mode `<leader>sR` seeds the selection; `<leader>sW` seeds
  the word under cursor. Prefer this over `:%s` for anything multi-file.
- `<leader>sg` grep, `<leader>sw` grep current word (n/v), `<leader>s/` grep open
  buffers, `<leader>/` fuzzy lines in the current buffer — all **snacks picker**.

### Finding code (pickers + LSP)

| Key | Finds |
|-----|-------|
| `<leader>sf` | files |
| `<leader>sF` | all files, including hidden + git-ignored |
| `<leader><leader>` | open buffers |
| `<leader>ss` / `gO` | document symbols (outline) |
| `<leader>sS` / `gW` | workspace symbols (see section below — VS Code Cmd+T) |
| `grd` | definition (`<C-t>` to return) |
| `grr` | references |
| `gri` | implementations |
| `grt` | type definition |
| `grD` | declaration |
| `K` | hover docs · `<leader>k` signature help |
| `<leader>sd` | diagnostics · `<leader>xx` Trouble panel |
| `<leader>e` | file explorer (snacks) |

### Buffers & windows

- Buffers: `<S-h>`/`<S-l>` (or `[b`/`]b`) prev/next, `<leader>1`..`9` jump by the
  ordinal shown in **bufferline**, `<leader>bb` pick-by-label, `<leader>bd` delete.
- Windows: `<leader>w{hjkl}` focus, `<leader>w{HJKL}` focus farthest,
  `<leader>wv`/`ws` split, `<leader>wc` close, `<leader>wo` close others.

### Git / review navigation

- `<leader>gg` lazygit, `<leader>gb` blame line, `<leader>gd` diff branch vs main
  (diffview), `<leader>gp`/`gi`/`gr` octo PR list / issue list / start review.
  Git hunk ops under `<leader>h` (gitsigns).

When in doubt about a key, `<leader>sk` searches keymaps and which-key shows
pending chains live (it pops instantly — `delay = 0`).

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
