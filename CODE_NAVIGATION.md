# Code navigation cheatsheet

Practical recipes for moving and operating on code with this config's plugins.
Flash is configured in `init.lua` (SECTION 3, search `flash.nvim`):

| Key | Mode | Action |
|-----|------|--------|
| `s` | n/x/o | `flash.jump()` |
| `S` | n/x/o | `flash.treesitter()` select |
| `r` | o | `flash.remote()` — jump, run a motion, return cursor |
| `R` | o/x | `flash.treesitter_search()` |

Commenting is Neovim's **native `gc` operator** (no Comment.nvim): `gcc` (line),
`gc{motion}`, `gc` in visual mode.

## Comment a property + its decorators from outside the class

Given a block like this, where blank lines sit above `@TreeParent` and below
`ownee` — so the three lines form a **paragraph**:

```ts
  @TreeParent({ onDelete: 'CASCADE' })
  @JoinColumn({ name: 'ownee_id' })
  ownee: BeneficiaryNode
```

The inner-paragraph textobject `ip` captures exactly those lines.

**Best — stay outside the class (Flash remote):**

```
gc r  →  type "ow" (or "@T")  →  press the label  →  ip
```

- `gc` — start the comment operator (operator-pending)
- `r` — Flash remote; labels appear
- type chars near the block, hit the label to land in that paragraph
- `ip` — inner paragraph = the decorator pair + the property

The 3 lines get commented and the cursor returns to where it started.

**Simpler — jump there, then comment (cursor moves):**

```
s  →  type "@T" / "ow"  →  label  →  gcip
```

**Why not `S` (treesitter)?** In the TypeScript grammar, decorators are
*siblings* of the field definition, not children, so a single treesitter node
usually won't capture all three without extra expansion. `ip` is more reliable
because the blank lines bound the block.

**No surrounding blank lines?** Use a count instead: land on the first line and
`gc2j` (current line + 2 down = 3 lines).
