# Setup instructions for an agent

You are reading this because someone pointed you at `github.com/SanyamPunia/agent-rules` and asked you to set it up. Do the whole thing yourself. Do not paste these steps back for the human to run.

Work out which of the two jobs they want. If it is ambiguous, do job 1, then ask whether they want job 2 on the current project.

---

## Job 1: install the rules on this machine

One command. It clones to `~/.agent-rules` (or pulls if already there) and installs.

```sh
curl -fsSL https://raw.githubusercontent.com/SanyamPunia/agent-rules/main/scripts/bootstrap.sh | sh
```

That symlinks every rule module into `~/.claude/rules/`, writes a managed `~/.claude/CLAUDE.md` importing the two always-on modules, and installs the `/init-rules` command. It backs up anything it replaces to a `.bak` sibling and is safe to re-run.

After it finishes:

1. Read the output. If it reports backing up an existing `~/.claude/CLAUDE.md`, open the `.bak` and tell the user what was in it, so they can decide what to merge back.
2. If `~/.claude/settings.json` has no `includeCoAuthoredBy` key, offer to add `"includeCoAuthoredBy": false`. The rules forbid AI co-author trailers, and this makes the harness enforce it rather than relying on the model to remember.
3. Tell the user the rules take effect in their next session.

If the machine has no network access to GitHub, ask them to clone manually and run `./scripts/install.sh` from the checkout.

## Job 2: scaffold a project

Run the scaffold script from the checkout, in the project directory:

```sh
~/.agent-rules/scripts/init-rules.sh --with <module> --with <module>
```

Pick the optional modules by **reading the project first**, not by guessing from its name:

| Add `--with` | When |
|---|---|
| `typescript` | the project is TypeScript |
| `state` | it uses Zustand, Redux, or a comparable client store |
| `data` | it owns a database or defines API endpoints |
| `seo` | it has public content or marketing pages |
| `ai-features` | it ships LLM-backed features |
| `three-js` | it renders 3D |

`base` is always included. `frontend` is added automatically when React or Tailwind is detected. Pass `--vendor` if the project is public or shared with people who will not have these rules installed, which copies the rule text in instead of importing it from the home directory.

Then fill in every `TODO` the script leaves, by reading the actual code:

- **Project overview.** One paragraph. What it is and who it is for.
- **Commands.** The real scripts from `package.json` or the Makefile. Mark the combined pre-push gate.
- **Stack declaration.** Verify every detected value and replace every placeholder with the real one. Read the stylesheet for the actual token names, an existing input for the actual focus pattern, an existing button for the actual radius. Do not leave a guess in this table, it is what every other rule reads from.
- **Architecture.** The seams and the non-obvious decisions only. Never restate what reading the directory tree already tells a reader.
- **Gotchas.** Leave the section empty if there are none yet. Only things that have already cost real time earn a line.

### Converting a project that already has a CLAUDE.md

Do not delete their file and start over. Instead:

1. Read the existing file end to end.
2. Diff it mentally against the modules in `base/`. Anything the modules already say, delete from the project file.
3. Anything the project file says that **contradicts** a module is a real decision. Keep it, move it under a `## Local overrides` heading, and state why in one line.
4. Anything genuinely local (architecture, gotchas, domain rules, deploy specifics) stays.
5. Add the import lines at the top and a Stack declaration filled from what you just deleted, since the old file's Tailwind section is usually where the real token names and focus pattern were written down.
6. Show the user the before and after line counts, and list anything you moved to overrides.

Never drop a rule silently. If you are unsure whether something is covered by a module, keep it and say so.

## What not to do

- Do not edit files under `base/` on the user's machine. They are symlinks into the checkout, so an edit changes the rules for every project at once. If a rule is wrong, say so and let the user decide.
- Do not commit or push anything unless asked.
- Do not add an AI co-author trailer to any commit you are asked to make.
