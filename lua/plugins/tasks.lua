local function find_libratory_root(startpath)
  local root = vim.fs.root(startpath or 0, ".git")
  return root and vim.fs.basename(root) == "libratory-app" and root or nil
end

local function start_overseer_task(name, cmd, cwd)
  local overseer = require("overseer")
  local task = overseer.new_task({
    name = name,
    cmd = cmd,
    cwd = cwd,
    components = {
      -- the default comparator is name-only, so same-named tasks in different
      -- packages would restart each other and dispose the task we just opened
      {
        "unique",
        replace = false,
        compare = function(a, b)
          return a.name == b.name and a.cwd == b.cwd
        end,
      },
      "default",
    },
  })

  task:start()
  task:open_output("vertical")
end

local function run_project_checks()
  local libratory_root = find_libratory_root()
  if not libratory_root then
    vim.notify("No project checks known for this workspace", vim.log.levels.WARN)
    return
  end

  local script = vim.fs.joinpath(libratory_root, "scripts", "check.sh")
  if vim.fn.executable(script) ~= 1 then
    vim.notify("scripts/check.sh is missing or not executable", vim.log.levels.WARN)
    return
  end

  start_overseer_task("./scripts/check.sh", { script }, libratory_root)
end

local function run_swift_package_tests()
  local package = vim.fs.root(0, "Package.swift")

  -- the app target has no Package.swift above it, but its logic all lives in LibratoryKit
  if not package then
    local libratory_root = find_libratory_root()
    package = libratory_root and vim.fs.joinpath(libratory_root, "ios", "LibratoryKit")
  end

  if not package or vim.fn.filereadable(vim.fs.joinpath(package, "Package.swift")) ~= 1 then
    vim.notify("Not inside a Swift package", vim.log.levels.WARN)
    return
  end

  start_overseer_task("swift test", { "swift", "test" }, package)
end

local function open_recent_overseer_output()
  local overseer = require("overseer")
  local tasks = overseer.list_tasks({})
  if vim.tbl_isempty(tasks) then
    vim.notify("No Overseer tasks found", vim.log.levels.WARN)
    return
  end

  table.sort(tasks, function(a, b)
    local a_time = a.time_start or a.time_end or 0
    local b_time = b.time_start or b.time_end or 0
    return a_time > b_time
  end)

  tasks[1]:open_output("float")
end

return {
  -- Overseer is for non-persistent project tasks you want to inspect inside Neovim.
  --
  -- Usage:
  --   ,cc  toggle the task list dock on the left
  --   ,cr  open OverseerRun through the current `vim.ui.select` backend (Snacks picker)
  --   ,ck  run the current project's checks (libratory-app `./scripts/check.sh`)
  --   ,cs  run `swift test` in the enclosing Swift package (libratory-app falls back to LibratoryKit)
  --   ,co  reopen the most recent Overseer task output in a float
  --
  -- `,ck` and `,cs` are just opinionated shortcuts for the project scripts you are likely
  -- to want often. These tasks are not persistent: quitting Neovim stops them. For persistent
  -- shells or dev servers, use the zellij-backed terminal flow on `,t` instead.
  {
    "stevearc/overseer.nvim",
    keys = {
      {
        ",cc",
        function()
          require("overseer").toggle({ enter = false, direction = "left" })
        end,
        desc = "Overseer: toggle task list",
      },
      {
        ",cr",
        "<cmd>OverseerRun<CR>",
        desc = "Overseer: run task",
      },
      {
        ",ck",
        function()
          run_project_checks()
        end,
        desc = "Overseer: project checks",
      },
      {
        ",cs",
        function()
          run_swift_package_tests()
        end,
        desc = "Overseer: swift test",
      },
      {
        ",co",
        function()
          open_recent_overseer_output()
        end,
        desc = "Overseer: open recent output",
      },
    },
    opts = {
      task_list = {
        direction = "left",
        min_width = { 40, 0.2 },
        max_width = 0.5,
      },
    },
  },
}
