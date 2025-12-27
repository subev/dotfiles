-- Direct test runner without plenary
-- Run with: nvim --headless -c "luafile tests/run_tests.lua"

local statement_jump = require('statement_jump')

local passed = 0
local failed = 0
local tests = {}

local function test(name, fn)
  table.insert(tests, {name = name, fn = fn})
end

local function assert_eq(expected, actual, message)
  if expected ~= actual then
    error(string.format("%s\nExpected: %s\nGot: %s", message or "Assertion failed", expected, actual))
  end
end

local function run_tests()
  print("=== Running statement_jump tests ===\n")
  
  for _, t in ipairs(tests) do
    io.write("Testing: " .. t.name .. " ... ")
    
    local ok, err = pcall(t.fn)
    
    if ok then
      print("✓ PASS")
      passed = passed + 1
    else
      print("✗ FAIL")
      print("  Error: " .. tostring(err))
      failed = failed + 1
    end
    
    -- Clean up between tests
    vim.cmd("bufdo! bwipeout!")
  end
  
  print(string.format("\n=== Results: %d passed, %d failed ===", passed, failed))
  
  if failed > 0 then
    vim.cmd("cquit 1")
  else
    vim.cmd("quit")
  end
end

-- ============================================================================
-- TESTS
-- ============================================================================

test("TypeScript properties: forward navigation", function()
  vim.cmd("edit tests/fixtures/type_properties.ts")
  vim.api.nvim_win_set_cursor(0, {4, 4})
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(5, pos[1], "Should jump from contentUrl (L4) to slug (L5)")
end)

test("TypeScript properties: backward navigation", function()
  vim.cmd("edit tests/fixtures/type_properties.ts")
  vim.api.nvim_win_set_cursor(0, {5, 4})
  
  statement_jump.jump_to_sibling({ forward = false })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(4, pos[1], "Should jump from slug (L5) to contentUrl (L4)")
end)

test("TypeScript properties: no-op at first", function()
  vim.cmd("edit tests/fixtures/type_properties.ts")
  vim.api.nvim_win_set_cursor(0, {4, 4})
  
  statement_jump.jump_to_sibling({ forward = false })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(4, pos[1], "Should not move from first property")
end)

test("TypeScript properties: no-op at last", function()
  vim.cmd("edit tests/fixtures/type_properties.ts")
  vim.api.nvim_win_set_cursor(0, {12, 4})
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(12, pos[1], "Should not move from last property")
end)

test("JSX elements: forward navigation", function()
  vim.cmd("edit tests/fixtures/jsx_elements.tsx")
  vim.api.nvim_win_set_cursor(0, {5, 8})
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(9, pos[1], "Should jump from HeaderContent (L5) to Header (L9)")
end)

test("JSX elements: backward navigation", function()
  vim.cmd("edit tests/fixtures/jsx_elements.tsx")
  vim.api.nvim_win_set_cursor(0, {9, 8})
  
  statement_jump.jump_to_sibling({ forward = false })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(5, pos[1], "Should jump from Header (L9) to HeaderContent (L5)")
end)

test("JSX elements: child with no siblings stays put", function()
  vim.cmd("edit tests/fixtures/jsx_elements.tsx")
  vim.api.nvim_win_set_cursor(0, {14, 10})
  
  statement_jump.jump_to_sibling({ forward = false })
  local pos1 = vim.api.nvim_win_get_cursor(0)
  assert_eq(14, pos1[1], "Should not jump backward from child with no siblings")
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos2 = vim.api.nvim_win_get_cursor(0)
  assert_eq(14, pos2[1], "Should not jump forward from child with no siblings")
end)

test("JSX elements: non-self-closing forward", function()
  vim.cmd("edit tests/fixtures/jsx_elements.tsx")
  vim.api.nvim_win_set_cursor(0, {13, 8})
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(16, pos[1], "Should jump from PersistentTabContainer (L13) to TabContainer (L16)")
end)

test("JSX elements: non-self-closing backward", function()
  vim.cmd("edit tests/fixtures/jsx_elements.tsx")
  vim.api.nvim_win_set_cursor(0, {16, 8})
  
  statement_jump.jump_to_sibling({ forward = false })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(13, pos[1], "Should jump from TabContainer (L16) to PersistentTabContainer (L13)")
end)

test("Destructuring: forward navigation", function()
  vim.cmd("edit tests/fixtures/destructuring.ts")
  vim.api.nvim_win_set_cursor(0, {5, 4})
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(6, pos[1], "Should jump from currentTab:tab (L5) to setCurrentTab (L6)")
end)

test("Destructuring: backward navigation", function()
  vim.cmd("edit tests/fixtures/destructuring.ts")
  vim.api.nvim_win_set_cursor(0, {6, 4})
  
  statement_jump.jump_to_sibling({ forward = false })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(5, pos[1], "Should jump from setCurrentTab (L6) to currentTab:tab (L5)")
end)

test("Statements: forward navigation", function()
  vim.cmd("edit tests/fixtures/statements.ts")
  vim.api.nvim_win_set_cursor(0, {3, 2})
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(4, pos[1], "Should jump from const a (L3) to const b (L4)")
end)

test("Statements: backward navigation", function()
  vim.cmd("edit tests/fixtures/statements.ts")
  vim.api.nvim_win_set_cursor(0, {4, 2})
  
  statement_jump.jump_to_sibling({ forward = false })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(3, pos[1], "Should jump from const b (L4) to const a (L3)")
end)

test("JSX attributes: forward navigation", function()
  vim.cmd("edit tests/fixtures/jsx_attributes.tsx")
  vim.api.nvim_win_set_cursor(0, {5, 6})  -- className attribute
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(6, pos[1], "Should jump from className (L5) to style (L6)")
end)

test("JSX attributes: backward navigation", function()
  vim.cmd("edit tests/fixtures/jsx_attributes.tsx")
  vim.api.nvim_win_set_cursor(0, {7, 6})  -- onClick attribute
  
  statement_jump.jump_to_sibling({ forward = false })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(6, pos[1], "Should jump from onClick (L7) to style (L6)")
end)

test("JSX attributes: no-op at last", function()
  vim.cmd("edit tests/fixtures/jsx_attributes.tsx")
  vim.api.nvim_win_set_cursor(0, {15, 8})  -- onClick on Button (last attribute of Button)
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(15, pos[1], "Should not move from last attribute")
end)

test("JSX attributes: no-op at first", function()
  vim.cmd("edit tests/fixtures/jsx_attributes.tsx")
  vim.api.nvim_win_set_cursor(0, {5, 6})  -- className attribute (first attribute)
  
  statement_jump.jump_to_sibling({ forward = false })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(5, pos[1], "Should not move from first attribute")
end)

test("Type declarations: forward navigation", function()
  vim.cmd("edit tests/fixtures/type_declarations.ts")
  vim.api.nvim_win_set_cursor(0, {8, 6})  -- Inside RecentPlayedItem type alias
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(13, pos[1], "Should jump from RecentPlayedItem (L8) to NotificationItem (L13)")
end)

test("Type declarations: backward navigation", function()
  vim.cmd("edit tests/fixtures/type_declarations.ts")
  vim.api.nvim_win_set_cursor(0, {13, 6})  -- Inside NotificationItem type alias
  
  statement_jump.jump_to_sibling({ forward = false })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(8, pos[1], "Should jump from NotificationItem (L13) to RecentPlayedItem (L8)")
end)

test("Type declarations: interface forward", function()
  vim.cmd("edit tests/fixtures/type_declarations.ts")
  vim.api.nvim_win_set_cursor(0, {21, 10})  -- Inside UserProfile interface
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(26, pos[1], "Should jump from UserProfile (L21) to AdminProfile (L26)")
end)

test("Type declarations: interface backward", function()
  vim.cmd("edit tests/fixtures/type_declarations.ts")
  vim.api.nvim_win_set_cursor(0, {26, 10})  -- Inside AdminProfile interface
  
  statement_jump.jump_to_sibling({ forward = false })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(21, pos[1], "Should jump from AdminProfile (L26) to UserProfile (L21)")
end)

test("Whitespace navigation: backward from empty line", function()
  vim.cmd("edit tests/fixtures/statements.ts")
  vim.api.nvim_win_set_cursor(0, {6, 0})  -- Empty line between const c and if statement
  
  statement_jump.jump_to_sibling({ forward = false })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(5, pos[1], "Should jump to const c (closest statement above empty line)")
end)

test("Whitespace navigation: forward from empty line", function()
  vim.cmd("edit tests/fixtures/statements.ts")
  vim.api.nvim_win_set_cursor(0, {6, 0})  -- Empty line between const c and if statement
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  assert_eq(7, pos[1], "Should jump to if statement (closest statement below empty line)")
end)

test("JSX cursor position: lands on tag name not angle bracket", function()
  vim.cmd("edit tests/fixtures/jsx_elements.tsx")
  vim.api.nvim_win_set_cursor(0, {5, 7})  -- On HeaderContent
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  
  -- Should jump to L9 (Header element)
  assert_eq(9, pos[1], "Should jump to Header element")
  
  -- Check that cursor is on 'H' (first char of tag name), not '<'
  local line = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1]
  local char_at_cursor = line:sub(pos[2] + 1, pos[2] + 1)
  assert_eq("H", char_at_cursor, "Cursor should be on 'H' of Header, not '<'")
end)

test("JSX cursor position: non-self-closing element", function()
  vim.cmd("edit tests/fixtures/jsx_elements.tsx")
  vim.api.nvim_win_set_cursor(0, {9, 7})  -- On Header
  
  statement_jump.jump_to_sibling({ forward = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  
  -- Should jump to L13 (PersistentTabContainer element)
  assert_eq(13, pos[1], "Should jump to PersistentTabContainer element")
  
  -- Check that cursor is on 'P' (first char of tag name), not '<'
  local line = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1]
  local char_at_cursor = line:sub(pos[2] + 1, pos[2] + 1)
  assert_eq("P", char_at_cursor, "Cursor should be on 'P' of PersistentTabContainer, not '<'")
end)

-- Run all tests
run_tests()
