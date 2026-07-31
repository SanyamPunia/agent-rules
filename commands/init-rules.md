---
description: Scaffold this project's CLAUDE.md from the installed rule modules
allowed-tools: Bash(*/init-rules.sh:*), Read, Edit, Glob, Grep
---

Run the `init-rules.sh` script from the agent-rules checkout in the current project, passing `$ARGUMENTS`. If you cannot find the script, look for it at `~/.claude/rules/../../agent-rules/scripts/init-rules.sh` or ask where the checkout lives.

Optional modules to add with `--with`, chosen by reading the project first:

- `typescript` if the project is TypeScript
- `state` if it uses Zustand, Redux, or a comparable client store
- `data` if it owns a database or defines API endpoints
- `seo` if it has public content or marketing pages
- `ai-features` if it ships LLM-backed features
- `three-js` if it renders 3D

Then fill in every TODO the script left, by reading the actual codebase:

- **Project overview**: one paragraph, what it is and who it is for.
- **Commands**: the real scripts from `package.json` or the Makefile, with the combined pre-push gate marked.
- **Stack declaration**: verify each detected value against the code. Read the stylesheet for the real token names, check an existing input for the real focus pattern, check an existing button for the real radius. Replace every placeholder with the actual value.
- **Architecture**: the seams and the non-obvious decisions only. Never restate what reading the directory tree already tells you.
- **Gotchas**: leave empty if there are none yet. Only things that have cost real time earn a line.

Do not restate anything the imported modules already cover. If the project genuinely needs to override a shared rule, state the override explicitly and say why.
