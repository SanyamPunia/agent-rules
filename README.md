# agent-rules

A shared ruleset for AI coding agents, extracted from the `CLAUDE.md`, `AGENTS.md`, and `.cursor/rules` files of a dozen real projects and deduplicated into modules you import instead of retype.

The problem it solves: about two thirds of a typical project's `CLAUDE.md` is the same as every other project's. You retype it each time, it drifts, and by the third repo the focus ring in one project contradicts the focus ring in another. This keeps the portable rules in one place and leaves each project's file holding only what is genuinely local.

Works with Claude Code out of the box. The rule files are plain markdown, so Cursor, Codex, Copilot, and anything else that reads an instructions file can use them too.

## Install

```sh
git clone https://github.com/SanyamPunia/agent-rules.git
cd agent-rules
./scripts/install.sh
```

That symlinks every module into `~/.claude/rules/`, writes a `~/.claude/CLAUDE.md` importing the two always-on ones, and installs the `/init-rules` command. Symlinks mean `git pull` here updates every project at once. Pass `--copy` if you would rather have real files.

An existing `~/.claude/CLAUDE.md` is backed up to `CLAUDE.md.bak` and the import block is prepended, so nothing is lost.

## Scaffold a project

```sh
cd ~/code/my-app
~/path/to/agent-rules/scripts/init-rules.sh --with typescript --with data
```

Or from inside Claude Code, `/init-rules --with typescript --with data`, which additionally reads the codebase and fills in the placeholders.

It writes a `CLAUDE.md` that is only imports plus a short project-specific skeleton, and symlinks `AGENTS.md` to it so other tools read the same file. Use `--vendor` in a public repo to copy the rule text in rather than importing it from your home directory.

## Modules

| Module | Loaded | Covers |
|---|---|---|
| `base.md` | always | Writing style, git and commit discipline, code style, process |
| `frontend.md` | on React or Tailwind | Design engineering, Tailwind mechanics, interaction contract, modals, data fetching |
| `typescript.md` | opt-in | Strictness, type derivation, declaration files |
| `state.md` | opt-in | Zustand and Immer, store ownership, dirty tracking, undo |
| `data.md` | opt-in | Schema as source of truth, query discipline, API boundary, pagination, auditing |
| `seo.md` | opt-in | Server rendering, metadata, structured data, content uniqueness |
| `ai-features.md` | opt-in | The propose-then-validate boundary, tool coverage, provider handling |
| `three-js.md` | opt-in | Geometry, disposal, exporters |

`base.md` and `frontend.md` are the two that pay for themselves immediately. `frontend.md` opens by telling the agent to skip it when the project has neither React nor Tailwind, so it stays quiet in a Python or Go repo.

## How the rules are written

**Rules are absolute, parameters are declared.** The rule is "library icons only, never a glyph standing in for an icon". Which library is a parameter your project's Stack declaration fills in. That is why a Lucide project and a Phosphor project can share one file. The same applies to color tokens, type scale, radius, and focus ring.

**Each rule earns its line.** Most of these exist because something broke. A confirm dialog that closed before its mutation finished. A rounded container whose row hover poked past the radius. A placeholder rendering larger than the text it replaced. Rules with no incident behind them were left out.

**No rule is stated twice.** If a rule belongs in `base.md` it is not repeated in `frontend.md`. A project file that restates an imported rule is a bug, because the two copies will diverge.

## Opinions you may want to change

These are preferences, not universal truths. Edit `base/base.md` before installing if you disagree.

- No em dashes and no sentence-joining semicolons in any generated text, on the grounds that both read as AI tells.
- No AI co-author trailers and no mention of the assistant in commit messages. Pair it with `"includeCoAuthoredBy": false` in `~/.claude/settings.json`.
- Commit and push only when explicitly asked, never proactively.
- Conventional commit prefixes, and one concern per commit rather than one large dump.
- Semantic color tokens with raw palette utilities and hex banned outright.

## Layout

```
base/           the rule modules
scripts/
  install.sh    install into ~/.claude
  init-rules.sh scaffold a project's CLAUDE.md
commands/
  init-rules.md the /init-rules slash command
```

## License

MIT
