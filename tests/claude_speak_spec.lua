-- Covers the picker behind <leader>tS: which of the hook's records a keypress
-- should read, and that it never reaches across panes or across projects.
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/nvim")

local speak = require("config.claude_speak")

local failed = false
local function check(ok, msg)
  if not ok then
    failed = true
    io.stderr:write("FAIL: " .. msg .. "\n")
  end
end

local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")

local function write(rel, contents)
  local path = dir .. "/" .. rel
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  vim.fn.writefile({ contents }, path)
  return path
end

local function json(record)
  return vim.json.encode(record)
end

-- Paths that do not exist resolve to themselves, so an uncanonicalised cwd
-- gives a deterministic slug for the test.
local CWD = "/proj/one"
local OTHER = "/proj/two"

-- The directory names the picker will look in, taken from the module so the
-- fixtures below exercise the real lookup path rather than a shadow directory.
local ONE = speak.slug(CWD)
local TWO = speak.slug(OTHER)
local BAD = speak.slug("/proj/bad")

-- The hook and the picker have to agree on this directory and on the slug.
vim.env.CLAUDE_SPEAK_DIR = dir

-- The pane's own record wins, and names itself as the source.
local record = { text = "Refactored the parser.", cwd = CWD, slot = "claude_2", ts = os.time() }
write(ONE .. "/claude_2.json", json(record))
local got, source = speak.pick("claude_2", CWD)
check(got and got.text == "Refactored the parser.", "the pane's own record is used")
check(source == "claude_2", "a slot hit reports the slot as its source")

-- The record is written where the picker looked, so the checks above ran
-- against a real lookup rather than a directory `pick` never reads.
check(vim.fn.filereadable(dir .. "/" .. ONE .. "/claude_2.json") == 1, "the fixture is read through the picker's own path")

-- A pane with no record of its own gets nothing -- NOT the project's latest.
-- Several agents run side by side here, so latest.json is some other pane's
-- reply, and reading it aloud is the exact confusion the slot exists to stop.
write(ONE .. "/latest.json", json({ text = "Latest here.", cwd = CWD, slot = "", ts = os.time() }))
got, source = speak.pick("claude_9", CWD)
check(got == nil, "a slot miss must not become another pane's reply")
check(source == "claude_9", "and it still reports which pane was asked for")

-- Without a slot at all -- claude started outside sidekick -- same fallback.
got = speak.pick(nil, CWD)
check(got and got.text == "Latest here.", "no slot still finds the project's record")

-- The fallback must not cross projects. Another project's summary read aloud
-- here would be worse than saying nothing.
write(TWO .. "/latest.json", json({ text = "Another project.", cwd = OTHER, slot = "", ts = os.time() }))
got = speak.pick("claude_9", "/proj/three")
check(got == nil, "another project's record is never spoken")

-- A directory with no records at all is not an error, just nothing to say.
got = speak.pick("claude_2", "/proj/nothing-here")
check(got == nil, "an unknown project returns nothing rather than raising")

-- A turn that ended in a tool call is recorded with empty text on purpose, so
-- the picker must hand it back for the caller to report instead of treating it
-- as missing and replaying the previous turn.
write(ONE .. "/claude.json", json({ text = "", cwd = CWD, slot = "claude", ts = os.time() }))
got = speak.pick("claude", CWD)
check(got ~= nil, "an empty-text record is a record, not a miss")
check(got and got.text == "", "and it carries the empty text through")

-- A half-written or corrupt record is refused, never raised: the hook writes
-- atomically, but a cache directory outlives the code that wrote it. This
-- project has no latest.json, so a nil result proves the bad record was
-- rejected rather than shadowed by the fallback.
write(BAD .. "/claude_5.json", "{ this is not json")
local ok, err = pcall(speak.pick, "claude_5", "/proj/bad")
check(ok, "a corrupt record does not raise: " .. tostring(err))
check(speak.pick("claude_5", "/proj/bad") == nil, "a corrupt record is refused")

-- Nor is JSON that decodes to something which is not an object. [1,2,3] is a
-- Lua table, so a plain type() check would hand it back to be spoken from.
write(BAD .. "/claude_6.json", "[1,2,3]")
check(speak.pick("claude_6", "/proj/bad") == nil, "an array record is refused")
write(BAD .. "/claude_7.json", "42")
check(speak.pick("claude_7", "/proj/bad") == nil, "a scalar record is refused")

-- A corrupt slot record is a miss exactly like a missing one, and must not
-- fall through to another pane's reply either.
write(ONE .. "/claude_8.json", "{ this is not json")
check(speak.pick("claude_8", CWD) == nil, "a corrupt slot record does not fall back either")

vim.env.CLAUDE_SPEAK_DIR = nil
vim.fn.delete(dir, "rf")

if failed then
  os.exit(1)
end
print("claude_speak: ok")
