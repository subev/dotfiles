-- Global keymaps.
--
-- Pass `{}` (not `{ noremap = true }`) where the mapping should stay
-- recursive, and the empty mode string where it applies to several modes.
--
-- Uses `nvim_set_keymap` rather than `vim.keymap.set` for string right-hand
-- sides: `vim.keymap.set` always creates non-recursive mappings (it ignores
-- `noremap = false`), and a mode *table* creates one mapping per mode where a
-- bare `:map` creates a single mapping shared by all of them. Both would
-- change behaviour for the recursive mappings below.
--
-- An empty mode string is `:map`: normal, visual, select, operator-pending.
-- nvim_set_keymap rejects multi-character mode names such as "nvo".

local NVO = ""

-- vimscript `noremap` — all of normal, visual, select, operator.
local function nore(lhs, rhs, opts)
  vim.api.nvim_set_keymap(NVO, lhs, rhs, vim.tbl_extend("force", { noremap = true }, opts or {}))
end

-- Save / quit / windows
nore("<C-S>", ":w<CR>")
vim.api.nvim_set_keymap("i", "<C-S>", "<C-O>:w<CR><Esc>", { noremap = true })
vim.api.nvim_set_keymap("n", "<PageUp>", "<C-u>", { noremap = true })
vim.api.nvim_set_keymap("n", "<PageDown>", "<C-d>", { noremap = true })
nore("<S-CR>", "<Esc>")
vim.api.nvim_set_keymap("n", "U", "<C-R>", { noremap = true })
vim.api.nvim_set_keymap("v", "U", "gU", { noremap = true })
vim.api.nvim_set_keymap("n", "2", ":w<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
  "n",
  "3",
  [[:let @/='\C\<' . expand('<cword>') . '\>'<CR>:let v:searchforward=0<CR>n]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "4", "$", { noremap = true })
vim.api.nvim_set_keymap("v", "4", "$h", { noremap = true })
vim.api.nvim_set_keymap("n", "5", "%", {})
vim.api.nvim_set_keymap("v", "5", "%", {})
vim.api.nvim_set_keymap("n", "6", "^", { noremap = true })
vim.api.nvim_set_keymap("v", "6", "^", { noremap = true })
vim.api.nvim_set_keymap(
  "n",
  "8",
  [[:let @/='\C\<' . expand('<cword>') . '\>'<CR>:let v:searchforward=1<CR>n]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "9", "<C-o>", { noremap = true })
vim.api.nvim_set_keymap("n", "0", "<C-i>", { noremap = true })

-- Text objects
vim.api.nvim_set_keymap("n", "db", "V$%d", { noremap = true })
vim.api.nvim_set_keymap("n", "dc", "f(bhxdwda(", { noremap = true })
for _, m in ipairs({
  { "c9", "ci(" },
  { "ca9", "ca(" },
  { "d9", "di(" },
  { "y9", "yi(" },
  { "v9", "vi(" },
  { "ds9", "ds(" },
  { "da9", "da(" },
  { "c[", "ci[" },
  { "d[", "di[" },
  { "y[", "yi[" },
  { "v[", "vi[" },
  { "c{", "ci{" },
  { "d{", "di{" },
  { "y{", "yi{" },
  { "v{", "vi{" },
  { "c5", "cib" },
  { "d5", "dib" },
  { "y5", "yib" },
  { "v5", "vib" },
  { "yw", "yiw" },
  { "cq", "caq" },
  { "dq", "daq" },
  { "yq", "yiq" },
  { "vq", "vaq" },
  { "c'", "ciq" },
  { "d'", "diq" },
  { "da'", "daq" },
  { "y'", "yiq" },
  { "v'", "viq" },
  { "d4", "d$" },
  { "y4", "y$" },
}) do
  vim.api.nvim_set_keymap("n", m[1], m[2], {})
end
vim.api.nvim_set_keymap("n", "cw", "cw", { noremap = true })
vim.api.nvim_set_keymap("n", "dw", "dw", { noremap = true })
vim.api.nvim_set_keymap("n", "c6", "c^", { noremap = true })
vim.api.nvim_set_keymap("o", "<space>", "iW", { noremap = true })
vim.api.nvim_set_keymap("o", "a<space>", "aW", { noremap = true })
vim.api.nvim_set_keymap("n", "v<space>", "viW", { noremap = true })
vim.api.nvim_set_keymap("n", "c<space>", "ciW", { noremap = true })
vim.api.nvim_set_keymap("n", "d<space>", "daW", { noremap = true })
vim.api.nvim_set_keymap("n", "~", "~h", { noremap = true })
vim.api.nvim_set_keymap("n", "t9", "t(", { noremap = true })
vim.api.nvim_set_keymap("n", "t0", "t)", { noremap = true })
vim.api.nvim_set_keymap("n", "dt9", "dt(", { noremap = true })
vim.api.nvim_set_keymap("n", "dt0", "dt)", { noremap = true })
vim.api.nvim_set_keymap("n", "ct9", "ct(", { noremap = true })
vim.api.nvim_set_keymap("n", "ct0", "ct)", { noremap = true })
vim.api.nvim_set_keymap("n", "f9", "f(", { noremap = true })
vim.api.nvim_set_keymap("n", "f0", "f)", { noremap = true })
vim.api.nvim_set_keymap("n", "dC", "vf(%d", { noremap = true })
vim.api.nvim_set_keymap("n", "cC", "vf(%c", { noremap = true })

-- Yanking
vim.api.nvim_set_keymap("n", "yl", "^y$", { noremap = true })
vim.api.nvim_set_keymap("n", "Y", ":%y+<CR>", { noremap = true })
vim.api.nvim_set_keymap("v", "Y", "ygv']<esc>o<esc>p", { noremap = true })
vim.api.nvim_set_keymap("n", "dl", [[^d$"_dd]], { noremap = true })
vim.api.nvim_set_keymap("n", "<up>", "8<C-y>", { noremap = true })
vim.api.nvim_set_keymap("v", "<up>", "8<C-y>", { noremap = true })
vim.api.nvim_set_keymap("n", "<down>", "8<C-e>", { noremap = true })
vim.api.nvim_set_keymap("v", "<down>", "8<C-e>", { noremap = true })

-- Windows
vim.api.nvim_set_keymap("n", "§", "<C-w>v", { noremap = true })
vim.api.nvim_set_keymap("n", "<left>", "<C-w>h", { noremap = true })
vim.api.nvim_set_keymap("n", "<right>", "<C-w>l", { noremap = true })
vim.api.nvim_set_keymap("n", "<s-up>", "<C-w>k", { noremap = true })
vim.api.nvim_set_keymap("n", "<s-down>", "<C-w>j", { noremap = true })
nore("Q", "q")
nore("q", "<C-w>c")
nore(",n", ":vnew<CR>")
vim.api.nvim_set_keymap("n", "<space>4", "<c-6>", { noremap = true })
vim.api.nvim_set_keymap("n", ",o", [[<c-w>|]], { noremap = true })
vim.api.nvim_set_keymap("n", ",O", "<c-w>o", { noremap = true })

-- Searching
vim.api.nvim_set_keymap(
  "n",
  "<cr>",
  [[(v:hlsearch == 1) ? ':noh<cr>' : ":let @/ = '\\C\\<'.expand('<cword>').'\\>'<cr>:set hlsearch<cr>"]],
  { noremap = true, silent = true, expr = true }
)
vim.api.nvim_set_keymap(
  "v",
  "<cr>",
  [[y:let @/='<C-R>"'<CR>:let v:searchforward=1<CR>:set hlsearch<CR>]],
  { noremap = true }
)

-- Misc
vim.api.nvim_set_keymap("n", "<f5>", ":e!<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<space>7", ":silent ! open -a 'Brave Browser' %:p<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<space>tu", ":!npm run test:unit -- -u %<CR>", { noremap = true })
vim.api.nvim_set_keymap("c", "w!!", "w !sudo tee > /dev/null %", {})
vim.api.nvim_set_keymap(
  "n",
  "<leader>q",
  [[:let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>]],
  { noremap = true, silent = true }
)
nore(";", '"0p')
vim.api.nvim_set_keymap("v", "gp", [[<c-n>\\CP<esc>]], {})
vim.api.nvim_set_keymap("v", "gm", [[<c-n>\\C]], {})

-- Surround-style wrappers
vim.api.nvim_set_keymap("v", "<", [[c<<space>/><Esc>hhP]], { noremap = true })
vim.api.nvim_set_keymap("v", ">", [[c<><Esc>Pf>a</><Esc>P]], { noremap = true })
vim.api.nvim_set_keymap("v", "(", "S(", {})
vim.api.nvim_set_keymap("v", "9", "S)", {})
vim.api.nvim_set_keymap("v", ")", "S)", {})
for _, wrap in ipairs({ "[", "]", "{", "}" }) do
  vim.api.nvim_set_keymap("v", wrap, "S" .. wrap, {})
end
vim.api.nvim_set_keymap("v", '"', 'S"', {})
vim.api.nvim_set_keymap("v", "'", "S'", {})
vim.api.nvim_set_keymap("v", "`", "S`", {})

-- Merge conflicts and imports
local conflicts = require("config.conflicts")
vim.keymap.set("n", "g]", conflicts.go_next)
vim.keymap.set("n", "g[", conflicts.go_prev)
vim.keymap.set("n", "g1", conflicts.keep_left)
vim.keymap.set("n", "g2", conflicts.keep_both)
vim.keymap.set("n", "g3", conflicts.keep_right)
vim.keymap.set("n", "gi", conflicts.find_import)

-- Terminals and git helpers
vim.api.nvim_set_keymap("n", ",t", ":lua open_project_zellij_terminal()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", ",T", "<c-w>v:term<cr>inpm run typecheck<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", ",gl", [[<c-w>v<c-w>|:term<cr>igit ls<cr>]], { noremap = true })
-- The trailing `()<CR>` is carried over verbatim from the original; it moves
-- the cursor after the terminal opens rather than being a no-op.
vim.api.nvim_set_keymap("n", ",gP", ":lua git_log_patches()<CR>()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", ",gL", ":lua git_log_file()<CR>()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", ",G", ":vsplit<CR>:term<CR>igitco<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", ",gN", ":lua git_diff_main()<CR>()<CR>", { noremap = true })

-- Whitespace tweaks
nore("<Space>a", "a<Space><Esc>h")
nore("<Space>i", "i<Space><Esc>l")

-- Indentation
vim.api.nvim_set_keymap("n", "<Tab>", ">>", { noremap = true })
vim.api.nvim_set_keymap("n", "<S-Tab>", "<<", { noremap = true })
vim.api.nvim_set_keymap("v", "<Tab>", ">gv", { noremap = true })
vim.api.nvim_set_keymap("v", "<S-Tab>", "<gv", { noremap = true })

-- Scrolling
nore("<C-e>", "8<C-e>")
nore("<C-y>", "8<C-y>")
nore("<D-j>", "8<C-e>")
nore("<D-k>", "8<C-y>")
vim.api.nvim_set_keymap("n", "vv", "<C-w>", { noremap = true })

-- Path yanking
vim.api.nvim_set_keymap("n", "yp", [[:let @+ = expand('%')<CR>]], { noremap = true })
vim.api.nvim_set_keymap("n", "yP", [[:let @+ = expand('%') . ':' . line('.') . ':' . col('.')<CR>]], { noremap = true })
vim.api.nvim_set_keymap("n", "yF", [[:let @+ = expand('%:t')<CR>]], { noremap = true })
vim.api.nvim_set_keymap("n", "yf", [[:let @+ = expand('%:t:r')<CR>]], { noremap = true })

-- Sibling file jumps
vim.api.nvim_set_keymap("n", "gts", [[:e <C-R>=expand('%:r') . '.scss'<CR><CR>]], { noremap = true })
vim.api.nvim_set_keymap("n", "gtt", [[:e <C-R>=expand('%:r') . '.tsx'<CR><CR>]], { noremap = true })
vim.api.nvim_set_keymap("n", "gtj", [[:e <C-R>=expand('%:r') . '.js'<CR><CR>]], { noremap = true })
vim.api.nvim_set_keymap("n", "gtf", [[:!flow-to-ts %:p -o tsx<cr>:e <C-R>=expand('%:r') . '.tsx'<CR><CR>]], {})

-- Editing the config itself
nore("<leader>ve", ":vsplit $MYVIMRC<CR>")
nore("<leader>vu", ":source %<CR>")
vim.api.nvim_set_keymap("t", "<ESC><ESC>", [[<C-\><C-N>]], { noremap = true })
-- The trailing quoted text is not a comment: `:map` takes everything after the
-- right-hand side, so the original mapping really did emit it. Reproduced as-is.
vim.api.nvim_set_keymap(
  "n",
  "gf",
  [[<C-w>F<C-W>H " if the file exists open it in a vertical split on the left most window]],
  { noremap = true }
)

-- Diff mode
if vim.o.diff then
  nore("<leader>1", ":diffget LOCAL<CR>")
  nore("<leader>2", ":diffget BASE<CR>")
  nore("<leader>3", ":diffget REMOTE<CR>")
  -- Lowercase: the builtin is colors/darkblue.vim, and vim.cmd.colorscheme
  -- fails on a case-sensitive filesystem (the mismatch predates the migration).
  vim.cmd.colorscheme("darkblue")
end

-- LSP
vim.api.nvim_set_keymap("n", ",r", ":lua vim.lsp.buf.rename()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<space><space>", "<cmd>lua vim.lsp.buf.hover()<CR>", { noremap = true, silent = true })

-- Plugin mappings
vim.api.nvim_set_keymap("o", "ai", "aI", {})
vim.api.nvim_set_keymap("v", "ai", "aI", {})
vim.api.nvim_set_keymap("n", "{", "[%", {})
vim.api.nvim_set_keymap("n", "}", "]%", {})
vim.api.nvim_set_keymap("n", "]t", ":tabnext<cr>", {})
vim.api.nvim_set_keymap("n", "[t", ":tabprevious<cr>", {})

vim.api.nvim_set_keymap("n", "w", "<Plug>(smartword-w)", {})
vim.api.nvim_set_keymap("n", "b", "<Plug>(smartword-b)", {})
vim.api.nvim_set_keymap("n", "e", "<Plug>(smartword-e)", {})
vim.api.nvim_set_keymap("", "W", "<Plug>CamelCaseMotion_w", { silent = true })
vim.api.nvim_set_keymap("", "B", "<Plug>CamelCaseMotion_b", { silent = true })
vim.api.nvim_set_keymap("n", "E", "gE", { silent = true })
vim.api.nvim_set_keymap("v", "E", "<Plug>CamelCaseMotion_e", { silent = true })

vim.api.nvim_set_keymap("", "<F2>", [[\\A]], {})
vim.api.nvim_set_keymap("", "<F3>", [[\\C]], {})

-- fzf-backed searches
local fzf = require("config.fzf")
vim.keymap.set("n", "<space>6", fzf.rg_file_references)
vim.keymap.set("n", "<space>8", function()
  fzf.rg_x(0)
end)
vim.api.nvim_set_keymap("v", "<space>`", [[y:CustomBLines <c-r>"<cr>]], { noremap = true })

-- Folding
vim.api.nvim_set_keymap("n", "-", [[(foldclosed(line(".")) == -1) ? 'za':'zA']], { expr = true })
vim.api.nvim_set_keymap("v", "-", "zf", { noremap = true })
vim.api.nvim_set_keymap("n", "_", "zc", {})
