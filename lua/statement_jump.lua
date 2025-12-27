-- statement_jump.lua
-- Navigate between sibling nodes at the same treesitter nesting level
--
-- Usage:
--   require("statement_jump").setup({
--     next_key = '<C-j>',         -- Key for jumping to next sibling (default: <C-j>)
--     prev_key = '<C-k>',         -- Key for jumping to previous sibling (default: <C-k>)
--     center_on_jump = false,     -- Whether to center screen after each jump (default: false)
--   })

local M = {}

-- Plugin configuration
local config = {
  center_on_jump = false,  -- Whether to center screen (zz) after each jump
}

-- Check if node should be skipped (comments, empty nodes, punctuation)
local function is_skippable_node(node)
  if not node then
    return true
  end
  
  local node_type = node:type()
  
  -- Skip comment nodes
  if node_type:match("comment") then
    return true
  end
  
  -- Skip punctuation and delimiters
  local punctuation = {
    ["{"] = true, ["}"] = true,
    ["("] = true, [")"] = true,
    ["["] = true, ["]"] = true,
    [","] = true, [";"] = true,
    [":"] = true,
    ["<"] = true, [">"] = true,
    ["</"] = true, ["/>"] = true,
  }
  if punctuation[node_type] then
    return true
  end
  
  -- Skip JSX opening/closing tags (they're just delimiters)
  if node_type == "jsx_opening_element" or node_type == "jsx_closing_element" then
    return true
  end
  
  -- Skip empty nodes (nodes with no content)
  local start_row, start_col, end_row, end_col = node:range()
  if start_row == end_row and start_col == end_col then
    return true
  end
  
  return false
end

-- Check if a node type is a "meaningful unit" we want to jump between
local function is_meaningful_node(node)
  if not node then
    return false
  end
  
  local node_type = node:type()
  
  -- These are the types of nodes we want to jump between
  -- They represent complete "units" like statements, declarations, properties, etc.
  local meaningful_types = {
    -- Statements
    "expression_statement",
    "if_statement",
    "for_statement",
    "while_statement",
    "do_statement",
    "for_in_statement",
    "return_statement",
    "break_statement",
    "continue_statement",
    "throw_statement",
    "try_statement",
    "switch_statement",
    
    -- Declarations
    "lexical_declaration",
    "variable_declaration",
    "function_declaration",
    "class_declaration",
    "method_definition",
    "export_statement",
    "import_statement",
    
    -- TypeScript/JavaScript specific
    "property_signature",  -- For type definitions like `contentUrl: string;`
    "public_field_definition",
    "pair",  -- For object properties like `key: value`
    "type_alias_declaration",  -- For type aliases like `type Foo = Bar`
    "interface_declaration",  -- For interfaces like `interface Foo { ... }`
    
    -- JSX/TSX
    "jsx_self_closing_element",  -- Self-closing JSX like <div />
    "jsx_attribute",  -- JSX attributes like visible={true}
    -- Note: jsx_element is NOT included as it's a container node
    
    -- Destructuring
    "shorthand_property_identifier_pattern",  -- For destructured properties like `{ tab, setTab }`
    "pair_pattern",  -- For renamed destructured properties like `{ currentTab: tab }`
    
    -- Python
    "function_definition",
    "class_definition",
    "decorated_definition",
    "assignment",
    
    -- Lua
    "assignment_statement",
    "function_call_statement",
  }
  
  for _, type_name in ipairs(meaningful_types) do
    if node_type == type_name then
      return true
    end
  end
  
  return false
end

-- Get the node at cursor position
local function get_node_at_cursor(bufnr)
  -- Get treesitter parser
  local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
  if not lang then
    return nil, "No treesitter language found for filetype"
  end
  
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok or not parser then
    return nil, "No treesitter parser available"
  end
  
  local tree = parser:parse()[1]
  if not tree then
    return nil, "Failed to parse buffer"
  end
  
  local root = tree:root()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1 -- Convert to 0-indexed
  local col = cursor[2]
  
  -- Get the smallest node at cursor
  local node = root:descendant_for_range(row, col, row, col)
  if not node then
    return nil, "No node at cursor"
  end
  
  -- Special case: if we're on a jsx_opening_element or jsx_closing_element,
  -- treat the parent jsx_element as the meaningful node
  if node:type() == "jsx_opening_element" or node:type() == "jsx_closing_element" then
    local parent = node:parent()
    if parent and parent:type() == "jsx_element" then
      return parent, parent:parent()
    end
  end
  
  -- Special case: if we're on a container node (like statement_block, object, etc.)
  -- where cursor is on whitespace/between children, find the closest meaningful child
  local container_types = {
    ["statement_block"] = true,
    ["object"] = true,
    ["object_type"] = true,
    ["array"] = true,
  }
  
  if container_types[node:type()] then
    -- Find the closest meaningful child node to the cursor position
    local closest_before = nil
    local closest_after = nil
    local min_dist_before = math.huge
    local min_dist_after = math.huge
    
    for child in node:iter_children() do
      if is_meaningful_node(child) then
        local child_start_row = child:start()
        
        if child_start_row < row then
          -- Child is before cursor
          local dist = row - child_start_row
          if dist < min_dist_before then
            min_dist_before = dist
            closest_before = child
          end
        elseif child_start_row > row then
          -- Child is after cursor
          local dist = child_start_row - row
          if dist < min_dist_after then
            min_dist_after = dist
            closest_after = child
          end
        else
          -- Child is on the same line as cursor, use it
          return child, node
        end
      end
    end
    
    -- Return a special marker indicating we're on whitespace
    -- We'll handle this specially in the jump function
    if closest_before or closest_after then
      return {
        _on_whitespace = true,
        closest_before = closest_before,
        closest_after = closest_after,
        parent = node,
      }, node
    end
    -- If no meaningful children found, fall through to normal logic
  end
  
  -- Walk up the tree until we find a "meaningful" node that represents
  -- a complete unit we want to jump between (like a property_signature, statement, etc.)
  local current = node
  while current do
    -- Special case: if current is jsx_opening_element or jsx_closing_element,
    -- use the parent jsx_element instead
    if current:type() == "jsx_opening_element" or current:type() == "jsx_closing_element" then
      local parent = current:parent()
      if parent and parent:type() == "jsx_element" then
        return parent, parent:parent()
      end
    end
    
    if is_meaningful_node(current) then
      return current, current:parent()
    end
    current = current:parent()
  end
  
  -- Fallback: if we didn't find a meaningful node, just use the first non-skippable node
  current = node
  while current and is_skippable_node(current) do
    current = current:parent()
  end
  
  if current then
    return current, current:parent()
  end
  
  return nil, "No valid node found at cursor"
end

-- Get all non-skippable children of a parent node
local function get_sibling_nodes(parent)
  if not parent then
    return {}
  end
  
  local parent_type = parent:type()
  local siblings = {}
  for child in parent:iter_children() do
    if not is_skippable_node(child) then
      -- Skip identifier nodes that are JSX tag names (direct children of jsx elements)
      local skip_jsx_identifier = child:type() == "identifier" and 
        (parent_type == "jsx_element" or 
         parent_type == "jsx_self_closing_element" or
         parent_type == "jsx_opening_element")
      
      if not skip_jsx_identifier then
        table.insert(siblings, child)
      end
    end
  end
  
  return siblings
end

-- Find the index of a node in a list
local function find_node_index(node, node_list)
  local node_start_row, node_start_col = node:start()
  
  for i, n in ipairs(node_list) do
    local n_start_row, n_start_col = n:start()
    if n_start_row == node_start_row and n_start_col == node_start_col then
      return i
    end
  end
  
  return nil
end

-- Find next/prev sibling node
local function get_sibling_node(node, parent, forward)
  if not node or not parent then
    return nil
  end
  
  local siblings = get_sibling_nodes(parent)
  if #siblings == 0 then
    return nil
  end
  
  local current_index = find_node_index(node, siblings)
  if not current_index then
    return nil
  end
  
  local next_index = forward and (current_index + 1) or (current_index - 1)
  
  return siblings[next_index]
end

-- Adjust cursor position for JSX elements to land on tag name instead of '<'
local function get_jsx_tag_position(node)
  local node_type = node:type()
  
  -- For jsx_self_closing_element: <Button />
  -- Structure: < [identifier] [attributes...] />
  if node_type == "jsx_self_closing_element" then
    local identifier = node:child(1)  -- child[0] is '<', child[1] is identifier
    if identifier and identifier:type() == "identifier" then
      return identifier:start()
    end
  end
  
  -- For jsx_element: <Button>...</Button>
  -- Structure: [jsx_opening_element] [children...] [jsx_closing_element]
  if node_type == "jsx_element" then
    local opening_element = node:child(0)
    if opening_element and opening_element:type() == "jsx_opening_element" then
      -- jsx_opening_element structure: < [identifier] [attributes...] >
      local identifier = opening_element:child(1)  -- child[0] is '<', child[1] is identifier
      if identifier and identifier:type() == "identifier" then
        return identifier:start()
      end
    end
  end
  
  -- For non-JSX nodes, return the original start position
  return node:start()
end

-- Main jump function
function M.jump_to_sibling(opts)
  opts = opts or {}
  local forward = opts.forward ~= false -- Default to forward
  
  local bufnr = vim.api.nvim_get_current_buf()
  
  -- Repeat for count
  for _ = 1, vim.v.count1 do
    local current_node, parent = get_node_at_cursor(bufnr)
    
    if not current_node then
      -- Silently do nothing if no node found
      return
    end
    
    if not parent then
      -- At root level, can't have siblings
      return
    end
    
    -- Special case: if we're on whitespace, jump to the closest statement
    if type(current_node) == "table" and current_node._on_whitespace then
      local target_node = forward and current_node.closest_after or current_node.closest_before
      
      if target_node then
        -- Add current position to jump list before moving
        vim.cmd("normal! m'")
        
        -- Get the appropriate cursor position (adjusted for JSX elements)
        local target_row, target_col = get_jsx_tag_position(target_node)
        vim.api.nvim_win_set_cursor(0, { target_row + 1, target_col }) -- Convert back to 1-indexed
        
        -- Center the screen on the new position (if enabled)
        if config.center_on_jump then
          vim.cmd("normal! zz")
        end
      end
      -- Always return after handling whitespace (no sibling navigation)
      return
    end
    
    -- Find sibling node
    local target_node = get_sibling_node(current_node, parent, forward)
    
    -- Jump to target or do nothing (no notification)
    if target_node then
      -- Add current position to jump list before moving
      vim.cmd("normal! m'")
      
      -- Get the appropriate cursor position (adjusted for JSX elements)
      local target_row, target_col = get_jsx_tag_position(target_node)
      vim.api.nvim_win_set_cursor(0, { target_row + 1, target_col }) -- Convert back to 1-indexed
      
      -- Center the screen on the new position (if enabled)
      if config.center_on_jump then
        vim.cmd("normal! zz")
      end
    else
      -- No sibling found - just stop silently (no-op)
      return
    end
  end
end

-- Setup function to configure keymaps
function M.setup(opts)
  opts = opts or {}
  
  -- Update configuration
  config.center_on_jump = opts.center_on_jump ~= nil and opts.center_on_jump or false
  
  local next_key = opts.next_key or '<C-j>'
  local prev_key = opts.prev_key or '<C-k>'
  
  vim.keymap.set('n', next_key, function()
    M.jump_to_sibling({ forward = true })
  end, { noremap = true, silent = true, desc = 'Jump to next sibling node' })
  
  vim.keymap.set('n', prev_key, function()
    M.jump_to_sibling({ forward = false })
  end, { noremap = true, silent = true, desc = 'Jump to previous sibling node' })
end

return M
