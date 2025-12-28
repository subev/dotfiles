# statement_jump.nvim

Smart, context-aware navigation for Neovim using treesitter. Navigate between sibling elements in your code with `<C-j>` and `<C-k>` while respecting structural boundaries.

## ✨ Features

- **Context-aware navigation**: Intelligently stays within code structures (`()`, `{}`, `[]`)
- **Universal**: Works across multiple languages (TypeScript, JavaScript, Python, Lua, etc.)
- **Smart**: Prioritizes innermost context when navigating nested structures
- **Fast**: Uses treesitter for accurate, syntax-aware jumping
- **Intuitive**: No-op at boundaries instead of unexpected jumps

## 🎯 What Can You Navigate?

Supports **11 different contexts** for intelligent sibling navigation:

### Method Chains
```typescript
obj
  .methodA()  // <C-j>
  .methodB()  // <C-j>
  .methodC()  // destination
```

### Object Properties
```typescript
const config = {
  foo: 123,    // <C-j>
  bar: 456,    // <C-j>
  baz: 789,    // destination
};
```

### Arrays
```typescript
const items = [
  element1,    // <C-j>
  element2,    // <C-j>
  element3,    // destination
];
```

### Function Parameters & Arguments
```typescript
function add(a: number, b: number, c: number) {
//           ^          ^          ^
//           Navigate between parameters
}

add(1, 2, 3);
//  ^  ^  ^
//  Navigate between arguments
```

### Import Statements
```typescript
import {
  UserRepository,      // <C-j>
  timezone,            // <C-j>
  username,            // destination
} from "~/domains/users";
```

### JSX Elements & Attributes
```tsx
<Component
  prop1={value1}    // <C-j>
  prop2={value2}    // destination
/>

<>
  <Header />        // <C-j>
  <Content />       // <C-j>
  <Footer />        // destination
</>
```

### Generic Type Parameters
```typescript
type Generic<T, U, V> = {
//           ^  ^  ^
//           Navigate between type parameters
};

function identity<A, B, C>(a: A, b: B, c: C) {}
//                ^  ^  ^
//                Navigate between generic parameters
```

### Union Types
```typescript
type Status = "pending" | "success" | "error";
//            ^           ^           ^
//            Navigate between union members

type Shape =
  | Circle      // <C-j>
  | Square      // <C-j>
  | Triangle    // destination
```

### Tuple Destructuring
```typescript
const [first, second, third] = getTuple();
//     ^      ^       ^
//     Navigate between tuple elements

const [count, setCount] = useState(0);
//     ^      ^
//     Navigate between destructured values
```

### Regular Statements
```typescript
const a = 1;        // <C-j>
const b = 2;        // <C-j>
if (condition) {}   // destination
```

## 🚀 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  dir = "~/path/to/your/dotfiles/lua/statement_jump.lua",
  config = function()
    require("statement_jump").setup()
  end,
}
```

### Manual

Add to your `init.lua`:

```lua
require("statement_jump").setup()
```

## ⚙️ Configuration

```lua
require("statement_jump").setup({
  next_key = '<C-j>',         -- Key for next sibling (default: <C-j>)
  prev_key = '<C-k>',         -- Key for previous sibling (default: <C-k>)
  center_on_jump = false,     -- Center screen after jump (default: false)
})
```

## 📖 Usage

| Key | Action |
|-----|--------|
| `<C-j>` | Jump to next sibling |
| `<C-k>` | Jump to previous sibling |
| `3<C-j>` | Jump 3 siblings forward (count support) |
| `<C-o>` | Jump back (standard Vim jumplist) |
| `<C-i>` | Jump forward (standard Vim jumplist) |

## 🧠 Smart Context Handling

### Context Boundaries
Navigation **stays within** structural boundaries:

```typescript
// Inside object - navigates between properties
{ foo: 1, bar: 2 }  // <C-j> goes from foo to bar

// Inside array - navigates between elements
[1, 2, 3]           // <C-j> goes from 1 to 2

// Inside function - navigates between statements
function test() {
  const a = 1;      // <C-j>
  const b = 2;      // destination (stays in function)
}
```

### Nested Context Priority

When inside nested structures, prioritizes the **innermost context**:

```typescript
someFunction(
  (data) => {
    const parsed = data.value;  // <C-j>
    if (parsed) { ... }          // Goes here (statement)
  },
  { message: "config" }          // Not here (outer argument)
)
```

### Whitespace Navigation

On empty lines, jumps to the closest statement:

```typescript
const a = 1;

                // <C-j> from here goes to next statement
                // <C-k> from here goes to prev statement

if (condition) {}
```

### JSX Cursor Positioning

Cursor lands on the tag name (not the angle bracket):

```tsx
<Header />   // Cursor on 'H', not '<'
<Footer />   // Cursor on 'F', not '<'
```

## 🎨 Supported Languages

Works with any language that has a treesitter parser:
- ✅ TypeScript/JavaScript
- ✅ TSX/JSX
- ✅ Python
- ✅ Lua
- ✅ Rust
- ✅ Go
- ✅ And more...

## 🔧 How It Works

1. Uses treesitter to understand code structure
2. Identifies "meaningful" nodes (statements, properties, elements, etc.)
3. Finds siblings at the same tree level
4. Navigates while respecting context boundaries
5. Prioritizes innermost context in nested structures

## 📊 Boundary Behavior

Navigation is **always safe**:
- At first sibling? `<C-k>` does nothing (no-op)
- At last sibling? `<C-j>` does nothing (no-op)
- Single element? No navigation (stays in context)
- No siblings? No navigation (stays in place)

## 🧪 Testing

The plugin includes comprehensive test coverage:

```bash
cd /path/to/dotfiles
bash tests/test_runner.sh
```

**55 tests covering:**
- Basic navigation (forward/backward)
- Boundary conditions (first/last/single)
- All navigation contexts
- Nested structures
- Edge cases

## 💡 Tips & Tricks

### Quick Navigation
```typescript
// Jump through multiple siblings quickly
3<C-j>  // Jump 3 forward
2<C-k>  // Jump 2 backward
```

### Explore Complex Objects
```typescript
const config = {
  database: { ... },    // <C-j>
  cache: { ... },       // <C-j>
  api: { ... },         // Quickly scan properties
};
```

### Review Import Lists
```typescript
import {
  useState,           // <C-j> through imports
  useEffect,          // to find what you need
  useCallback,
} from "react";
```

### Navigate Method Chains
```typescript
api
  .get("/users")      // <C-j>
  .then(parseJSON)    // <C-j>
  .catch(handleError) // Review chain structure
```

## 🤝 Contributing

Found a bug or have a feature request? Please open an issue!

## 📝 License

MIT

## 🙏 Acknowledgments

Built with [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
