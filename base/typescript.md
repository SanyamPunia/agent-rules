# TypeScript rules

Opt-in. Import from a project's `CLAUDE.md`.

- **Strict mode is on.** No `any` without a comment explaining why.
- **No `@ts-ignore`, `@ts-expect-error`, or `eslint-disable`** without a one-line comment justifying it.
- **`interface` for object shapes that might extend. `type` for unions, intersections, and one-offs.**
- **Explicit return types on exported functions.** Inference is fine for local helpers.
- **`readonly` arrays when the function does not mutate:** `function f(arr: readonly string[])`.
- **Untyped npm packages get a `.d.ts` under `types/`,** declaring only the APIs actually used. Never `declare module "x";` with no shape unless the module really is opaque.
- **Derive types, never restate them.** The schema file is the single source of truth. Infer row and payload types off it (`typeof table.$inferSelect`, `z.infer<typeof schema>`). Never hand-write an interface that mirrors a schema, it will drift.
- **Narrow stringly-typed columns and fields to unions** at the schema layer (`$type<Verdict>()`), so adding a value is a type change and not a migration.
- **Component-local types stay inline.** Only types used by more than one module move to a shared types file.
- **No auto-generated code in the repo.** No build artifacts, no `dist/`, no committed generated clients unless the build genuinely needs them checked in.
