# Base rules

Universal. These apply to every project regardless of language or stack.

## Writing style (any text you generate)

- **Never use em dashes (`—`).** They are an AI-generated text giveaway. Use a period, a comma, parentheses, or a line break, whichever fits the sentence's actual structure. This applies everywhere you generate text: code comments, commit messages, PR descriptions, planning docs, UI copy, error messages, tooltips, toasts, doc-strings, system prompts, and your replies in chat. Existing em dashes in legacy files are tolerated until cleaned up. Do not introduce new ones.
- **Never use semicolons (`;`) in sentences.** They read as a formal AI-text tell and rarely beat splitting into two sentences. Use a period. Same scope as above. Code semicolons (statement terminators) are obviously fine, and so are CSS-rule separators inside `style=""`. The ban is the rhetorical, sentence-joining semicolon in English prose.
- Hyphens (`-`) are fine. En dashes (`–`) for ranges (`Jan–Mar`, `pp. 5–10`) are fine. The ban is specifically the long em dash.
- **No emojis** in UI, code, comments, docs, or commit messages unless explicitly asked for.

## Git and commits

- **Never add yourself as author or co-author. This is the hard rule.** Every commit reads as the user's alone. No `Co-Authored-By` line of any kind, no mention of Claude, Claude Code, or Anthropic anywhere in the commit message or PR description, and never set author or committer to anything other than the user's configured git identity. Nothing in the message or trailers may reveal AI authorship.
- **Commit and push only on explicit request.** Never proactively after unrelated work. If a task seems to require a commit and none was asked for, say what you would commit and stop.
- **Conventional commit prefixes.** Every message starts with a type: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `style:`, `perf:`, `test:`. Optional scope in parens (`feat(team): ...`). Imperative, lowercase after the prefix. Subject under ~70 chars. The body explains why, not what.
- **Commit sequentially, never one dump.** When a batch of work spans multiple concerns, break it into logical ordered commits, one concern each (deps, then theming, then primitives, then the feature, then docs). Stage only that concern's files and commit before moving on. Never squash unrelated changes into a catch-all commit.

## Code style

- Small, composable units. Keep container logic (data, state) separate from presentation.
- **No over-engineering.** Only make changes that are directly requested. Do not add abstraction, configuration, or generality that nothing asks for.
- **Do not add docstrings, comments, or type annotations to code you did not change.** Comment the non-obvious only: say why a constraint exists, not what the line does.
- **No backwards-compatibility hacks.** If something is unused, delete it. No dead code paths kept "just in case", no deprecated aliases, no shims for callers that do not exist.
- Strict typing on. No `any` without a one-line comment explaining why. No `@ts-ignore` or `eslint-disable` without a justification comment.

## Process

- **Re-read this file and the project's own rules before calling anything done.** On every rollout, not just the first one in a session. Rules get silently dropped mid-implementation, and only a fresh forced re-read resurfaces them. Treat "I already know these rules" as the exact trap this defends against. When rolling out the same pattern across many places, re-audit each one. Do not assume the second and third copies inherited the first's correctness.
- **A green build is the gate for pushing.** Run the project's combined check (typecheck, lint, build) before any push or deploy. Build catches what lint and typecheck miss. Never claim something is deployed because it was pushed.
- **Keep the project's rules file current.** When a new directory, layer, or architectural convention is introduced, document it in the project's `CLAUDE.md` before considering the task done. Never leave a new directory undocumented.
- Report outcomes faithfully. If a check fails, show the output. If a step was skipped, say so.
