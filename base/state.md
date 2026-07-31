# Client state rules (Zustand + Immer)

Opt-in. Import from a project's `CLAUDE.md`.

## Ownership

- **All mutations go through slice actions.** Never mutate store state directly from a component.
- **Action pattern:**
  ```ts
  setFoo: (v) => set((state: SliceType) => { state.foo = v; })
  ```
- **Slices live one per file** (`store/<name>-slice.ts`) and compose in `store/index.ts`.
- **Split ephemeral state from document state.** UI and interaction state (active tool, zoom, cursor, open panel) goes in one slice. Persistent document state (the thing the user is actually editing) goes in another. They have different lifetimes and different persistence rules.
- **Do not prop-drill through the store.** Read from it in the component or handler that needs the value, not three levels up.

## Dirty tracking and persistence

- **Every action that mutates the document sets a dirty flag.** The only exceptions are the action that clears the flag and the action that resets to a fresh document (which sets it false).
- **Unsaved changes live in a local draft overlay** (localStorage or equivalent), separate from the loaded server state, so a reload does not silently discard work.
- **Store updates are synchronous. Persistence is explicit.** A save action writes to the server. Nothing persists as a side effect of a keystroke.
- **Adding a new persisted setting is a checklist, not one line:** the type, the storage key, the draft-overlay entry, the update action, the exported action, and the hook that exposes it. Miss one and the setting silently fails to round-trip.

## Rendering

- **Transient interaction state lives in refs, never React state.** Drag position, hover target, selection anchor. React state re-renders, and a drag does not need that.
- **Never read `ref.current` during render.** Write in effects, read in events.
- **Canvas-style components that read the store but must not re-render subscribe imperatively:** `useStore.subscribe(() => draw())` and read via `useStore.getState()` inside the draw callback.
- **Memoize expensive derivations from store state,** not cheap ones.
- **Wrap handlers passed into effect dependencies** so the effect does not re-run on every render.

## Undo

- **Push an undo snapshot before any destructive bulk mutation:** clear, regenerate, import, load-sample, resize. Not before incremental edits.
