Always use Context7 MCP when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.

# Skills — Proactively Load Before Implementation

Before starting any non-trivial implementation (new features, refactors, UI work), **always check available skills and load the relevant ones**. Don't wait for the user to ask — load them proactively during the planning phase so they inform the design and implementation.

- **React components / UI work** → load `vercel-react-best-practices` and `vercel-composition-patterns`
- **UI review / accessibility / design audit** → load `web-design-guidelines`
- **React Router / routing / loaders / actions** → load `react-router-framework-mode`
- **Complex TypeScript types** → load `typescript-advanced-types`
- **Performance optimization** → load `performance`
- **Figma implementation** → load `implement-design`
- **Drizzle ORM / database work** → load `drizzle-orm`
- **Web app testing** → load `webapp-testing`

When in doubt about whether a skill applies, load it anyway — the cost is low and the benefit of having the right patterns in context is high.

If none of the listed skills seem to cover the task at hand, use the `find-skills` skill to search for and discover additional skills that might help.

I am in the process of adapting `jj` on top of `git`. So if you know how juijicy, we can utilize it and you can teach me some things that you cannot easily do with git.
I also have `gh` so when I am talking about `PR`s and `CI` that use it.

CRITICAL when generating new code (not when refactoring existing such) don't add comments unless really needed. But don't remove existing comments, if they are there there is probably a reason. If you've just produced fresh code leave only if really important. Code should be self documenting.

When implementing Figma designs with icons, create a new icon along with the others following existing convention and put a meaningful svg close to what the design is showing, but with a TODO to later replace it.

Don't use barel index files

If implementing something looks like an overkill always warn that things are getting complicated, don't just blindly bring complex solutions without confirming first. Especially in cases where it feels it deviates the community standard.

# Bug Fix Workflow: Test First

When fixing a bug, **always write a failing test first** that demonstrates the broken behavior. Verify the test fails for the expected reason, then fix the implementation, and finally verify the test passes. This applies to all bug fixes — no exceptions.

# E2E Testing - ALWAYS ASK FIRST

**NEVER run E2E tests without asking the user first.**

When user wants E2E tests:

- **Prefer:** `cd e2e && pnpm e2e:dev` (fast, requires dev server running, some tests may fail)
- **Avoid:** `pnpm test:e2e` (slow Docker setup, containers stay running if tests fail on localhost:3000)
- **If Docker used:** Remind user to check `docker ps` and clean up with `docker compose -f docker-compose.e2e.yml down`

# Code Style

- When writing e2e tests avoid using waitForTimeout() at all costs, instead add data-testid attributes wherever needed to ensure elements get shown/hidden. Always add timeouts when waiting (aim for 1s), things need to fail quickly if they happen to fail.
- **E2E Timeout Rule**: ALWAYS use `{ timeout: 1000 }` (1 second) in E2E test assertions (Playwright). The system must remain blazing fast - things should fail quickly. DO NOT use longer timeouts without explicit user approval. Extreme cases (e.g., external payment systems) are exceptions.
- **Browser Component Tests**: Do NOT add `{ timeout }` to `expect.element()` — the default `expect.poll.timeout` is already 1000ms. Only override if you have a specific reason.
- When writing typescript definitions aim to use `type` instead of `interface`

## Type Consistency: `null` vs `undefined`

- Prefer `string | null` over `string | undefined` for optional values, especially when data comes from APIs
- **Code smell patterns - refactor when encountered:**
  - `?? undefined` - converting null to undefined
  - `?? null` - converting undefined to null
  - `|| undefined` - same issue
  - `|| null` - same issue
- If a prop comes from an API as `T | null`, the component should accept `T | null` directly
- Don't create type mismatches that require conversion at call sites
- Optional boolean props with sensible defaults (e.g., `isEnabled?: boolean` defaulting to `false`) are acceptable

# Committing Changes

**ALWAYS ask for user approval before committing changes.**

Before committing:

1. Show a summary of all changes being committed
2. Explain what was fixed/changed and why
3. Wait for explicit user approval
4. Only commit after receiving approval

Never commit changes without first getting user confirmation.

## React Best Practices

### Avoid useEffect When Possible

Before using `useEffect`, consider if you actually need it. Most use cases can be replaced with better patterns:

**❌ Don't use useEffect for:**

- Deriving state from props or other state → Use regular variables during render
- Synchronizing external state that changes → Use derived state
- Transforming data for rendering → Compute during render
- Updating state based on prop changes → Derive the value or use the `key` prop to reset

**✅ Do use useEffect for:**

- Truly synchronizing with external systems (DOM APIs, third-party libraries, network requests)
- Side effects that must happen after render (analytics, logging)
- Subscriptions that need cleanup

**Reference:** https://react.dev/learn/you-might-not-need-an-effect

### React Compiler handles most memoization — but not all cases

React Compiler auto-adds `useCallback`/`useMemo` for component render optimizations, so don't add them explicitly in typical component code. However, **you still need explicit `useCallback`/`useMemo` when a stable reference is required by a consuming API** (e.g., `useSyncExternalStore`'s `subscribe` argument, which re-subscribes on every render if it receives a new function reference). Use your judgement.

**Examples:**

```tsx
// ❌ Bad: Using useEffect to sync state
const [value, setValue] = useState("");
useEffect(() => {
  setValue(propValue);
}, [propValue]);

// ✅ Good: Derive state or use key
const value = propValue; // Just use the prop directly
// OR reset component with key if needed: <Component key={propValue} />

// ❌ Bad: Using useEffect to compute derived data
const [filtered, setFiltered] = useState([]);
useEffect(() => {
  setFiltered(items.filter((item) => item.active));
}, [items]);

// ✅ Good: Compute during render
const filtered = items.filter((item) => item.active);
```

## Database Migrations (Drizzle ORM)

Don't write the migrations on your own, change the schema and generate such.

When working with Drizzle ORM or similar migration-based database tools:

### Merge/Rebase Strategy for Migration Conflicts

When merging or rebasing branches with migration conflicts:

```bash
# 1. Accept incoming changes for generated migration files
git checkout --theirs drizzle/meta/*.json

# 2. Resolve any code conflicts manually (keep your schema.ts changes)

# 3. Remove duplicate migration SQL files (keep incoming, remove yours)
git rm drizzle/XXXX_your_old_migration.sql  # if you had a conflicting migration number

# 4. Stage resolved conflicts
git add .

# 5. Generate fresh migration from your schema changes
pnpm db:generate  # or npx drizzle-kit generate

# 6. Add new migration and complete merge
git add drizzle/ && git commit
```

**Key points:**

- Accept ALL incoming generated files (snapshots, journals, metadata)
- Keep YOUR schema.ts changes (source of truth)
- Remove YOUR old migration SQL if both branches created same migration number
- Generate ONE fresh migration for your changes
- Complete merge in a single commit

**Never:**

- Manually edit generated migration SQL files during merge
- Try to merge migration file contents
- Leave duplicate migration numbers

This pattern applies to any migration-based ORM (Drizzle, Prisma, TypeORM, etc.).
