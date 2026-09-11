-- Resolve the Sidekick terminal shown in a window, if any. Shared because the
-- failure mode is a silent nil: a copy that drifts (renamed window var, moved
-- Sidekick module) stops resolving and the caller just quietly does nothing.
local M = {}

---@param win integer
---@return sidekick.cli.Terminal?
function M.from_win(win)
  local id = vim.w[win].sidekick_session_id
  local mod = package.loaded["sidekick.cli.terminal"]
  return id and mod and mod.get(id)
end

return M
