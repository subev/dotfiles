# Shared personal preferences

These are my global preferences for Codex, Claude Code, and OpenCode. Use the
current task and repository instructions to resolve project-specific details.
An explicit request authorizes the work it describes; don't ask again for the
same approval.

## Communication and code references

- Match the detail to the question and the time available. Lead with the result
  or behavior; use judgment about when a short answer or a deeper explanation helps.
- When it helps narrow my attention, cite the important code with small, verified
  line ranges beside the explanation. I use these references to open and highlight
  code in Neovim from an AI terminal pane. Prefer unambiguous paths and the
  `path:start-end` convention where the client supports it; follow the client's
  required link format otherwise. Recheck locations after edits; don't guess them.
- When explaining a flow, connect the useful steps: what triggers it, what calls
  what, how the data changes, and where the result goes. Give separate references
  for distinct files or blocks. Don't turn every answer into a full call trace or
  require a citation for every sentence.
- Prefer simple, established solutions. Point out material complexity or tradeoffs
  before expanding scope; don't interrupt routine work for minor choices.

## Documentation and tools

- Use relevant available skills when they materially help the task. Don't load
  skills solely because of matching keywords or install new ones by default.
- For library/API questions, use current documentation when needed. Prefer
  Context7 when available and useful, or the library's official documentation.
- Use `gh` for GitHub PRs and CI when available. Respect the repository's existing
  Git or Jujutsu (`jj`) workflow; don't migrate it automatically. Useful `jj`
  techniques are welcome when relevant.

## Code style

- Follow nearby code and test conventions. Prefer TypeScript `type` to `interface`.
- Avoid barrel index files for re-exports.
- Default to no new comments. Comment only on non-obvious intent, constraints,
  invariants, or tradeoffs, briefly. Don't narrate the code or add docstrings to
  obvious functions. Keep useful existing comments; correct or remove stale ones
  when touching the relevant code.
- Preserve API nullability through consuming types; avoid needless conversions
  between `null` and `undefined`. Prefer `null` for explicit absence in API data,
  while respecting existing contracts and optional-property semantics.
- In React, derive values during render when possible; use effects for actual
  synchronization with external systems. Check whether React Compiler is enabled
  before assuming it handles memoization; add memoization only for a concrete need.
- Reuse existing icons and follow the project's asset conventions. Avoid inventing
  placeholder assets when the design or an established icon set already provides them.

## Testing

- Verify changes with focused, meaningful checks that fit the repository. For bugs,
  prefer a regression test that fails for the right reason before the fix when
  practical. Don't manufacture tests for trivial changes or mirror implementation.
- Ask before running Docker-based or full E2E suites unless already authorized.
  Get commands and environment requirements from the current repository.
- Prefer deterministic waits and stable selectors in browser tests over fixed
  sleeps such as `waitForTimeout()`. Use the project's timeout conventions and
  realistic bounds; don't impose a universal one-second timeout.

## Database migrations

- For schema-generated migration workflows such as Drizzle, change the schema and
  use the repository's generator. Follow its migration and conflict-resolution
  procedure; don't hand-merge generated metadata or assume migrations can be
  deleted or regenerated after they have been applied.

## Git and PRs

- Commit only when I explicitly request or approve it. A request to implement a
  change alone is not permission to commit. Summarize the intended changes when
  asking for approval; don't re-ask if the commit is already authorized.
- Match the repository's commit convention and scopes; inspect recent history.
  Otherwise use Conventional Commits: `type(scope): imperative summary`, a
  lowercase subject of at most 72 characters, and a scope only when meaningful.
  Use ticket/PR references where the repository already does.
- Explain why and what verifies the change in commit/PR bodies, with detail suited
  to the change and repository conventions.
- Don't add AI attribution: no `Co-Authored-By` or `Claude-Session` trailers,
  generated-by footers, or AI session links in commits or PR descriptions.
