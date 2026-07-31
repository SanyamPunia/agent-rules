# Frontend rules (React + Tailwind)

Applies to any project with React and Tailwind. If the project has neither, skip this file.

Where a rule references a project-specific choice (icon library, color tokens, type scale, radius, focus ring), the project's own `CLAUDE.md` declares the value in its **Stack declaration** block. The rule itself is not negotiable, only its parameter.

---

## Design engineering

### Tailwind mechanics

- **`size-*` over `w-*` + `h-*` when both dimensions are equal.** `size-6` not `w-6 h-6`, `size-full` not `w-full h-full`. Use separate `w-*`/`h-*` only when the dimensions actually differ.
- **`cn(...)` for class composition.** Never string-concatenate conditional classes.
- **`shrink-0`, never `flex-shrink-0`.**
- **`inset-0` over `top-0 left-0 right-0 bottom-0`.**
- **`gap-*` on flex/grid parents, not `space-*` utilities.**
- **Canonical classes over arbitrary values.** `h-11` not `h-[44px]`, `min-w-110` not `min-w-[440px]`. Arbitrary values only when no token fits, and justify with a comment when non-obvious.
- **Reusable class strings belong in a shared primitive or `@layer components`,** not re-typed inline at each call site.

### Color

- **Semantic tokens only. No raw palette utilities, no hex, no `text-[...]`.** Do not write `zinc-*`, `blue-*`, `bg-white`, or `#hex` in components. Color comes from the project's token set (surfaces, text tones, strokes, hovers, brand). If a color you need has no token, add the token to the stylesheet and the design-system doc first, then use it.
- **The token to semantic mapping lives in exactly one file.** A data-layer function returns a semantic tone (`up` / `warning` / `danger`), never a color class. Never write a local `Record<Tone, string>` inside a component. That is how a badge, a dot, and a chart drift apart.
- **Never hardcode a color for a value that has a tone.** Derive it from the tone map, always.
- **Every surface works in light and dark.** Never assume a background. Check both before calling a change done. Theme-dependent visuals switch via the `dark:` variant, not by reading the resolved theme in JS during render (that causes a hydration flash).
- **Anything filled with a theme-constant color pins its text color inline** (`color: "#fff"`), never a brand token, because brand tokens invert in dark.
- **No fill or stroke token may share a hex with a surface it can sit on.** Dark hovers on elevated surfaces go lighter, not darker. Scrims need `dark:bg-black/60`.
- **Surface edges use the opaque stroke token, never `ring-foreground/10`.** A translucent foreground ring composites to a different gray than neighboring control borders and reads visibly darker in dark mode. The translucent ring is only correct as an inset outline on an arbitrary color fill.

### Typography

- **Use the project's named type scale.** No ad-hoc `text-[15px]`. If the project has no named scale, `text-xs` and `text-sm` carry the UI.
- **Placeholder font size must match the input's font size, set explicitly.** A `text-sm` input needs `placeholder:text-sm`. The browser default renders placeholders at a larger base size, so an explicit matching `placeholder:text-*` is required on every `<input>`, `<textarea>`, and form control with a placeholder. Divergent placeholder sizes are never allowed.

### Icons and glyphs

- **Library icons only. Never a glyph or text character standing in for an icon.** Banned as icons anywhere in the UI: `› > → ← ↻ ↗ · • ★ ✓ ✗ … / —`. Use the icon component instead (`ChevronRight`, `ArrowRight`, `Check`, `X`, `MoreHorizontal`, `RefreshCw`, `ExternalLink`, `Minus`). If you catch yourself writing `<span>›</span>`, swap it for an icon.
  - This includes things that do not feel like icons: **separators** (a `Separator` component, not `·`), **breadcrumb dividers** (a chevron, not `/`), **empty-value placeholders** (a `Minus` icon, not `—`, which is why formatters should return `null` rather than an em dash), and **state suffixes** (a `BadgeCheck` icon, not the literal text `(confirmed)`).
  - Exceptions: literal punctuation inside prose copy, mathematical operators (`+`, `=`), and a trailing ellipsis inside loading copy. CLI output is exempt, it is not UI.
- **No text-based separators in metadata rows.** Never `·` or `•` between items like "email · joined date". Render an inline dot element instead:
  ```tsx
  <span aria-hidden="true" className="inline-block size-1 shrink-0 rounded-full bg-<stroke-token>" />
  ```
  inside a `flex items-center gap-1.5` parent. The dot is `size-1` (4px). `size-0.5` reads as invisible. It carries lighter visual weight than a middot, lines up with body text, and does not drift off the baseline at any font size. Exception: `<option>` inside a native `<select>` can only render plain text, so use ` - ` (plain hyphen with spaces) there.
- **Icons, never emojis.**
- **Consistent icon sizing** via the size scale, never width/height attributes. `size-4` inline and in body, `size-3.5` in dense text and badges, `size-5` in headers.
- **Accessible names.** Decorative icons get `aria-hidden="true"`. An icon carrying meaning on its own gets `role="img"` plus `aria-label`.
- If the project uses **Phosphor**: import the `*Icon`-suffixed exports only (`CheckIcon`, `XIcon`, `CaretDownIcon`). The bare names are deprecated in 2.1+ and will be removed. Server components must import from `@phosphor-icons/react/dist/ssr`, since the main barrel pulls in `createContext` and throws in RSC.
- **No em dashes or semicolons in user-facing copy.** Labels, placeholders, descriptions, empty states, toasts, button text, headings. See base rules.

### Interactive elements

- **Press feedback: `active:scale-[0.98]` on every button, icon button, and tappable card, always paired with `transition-all`.** Never ship a click target with zero press feedback, it feels broken. If the element already had `transition-colors`, upgrade it to `transition-all` so both properties animate. Native form controls (`input[type=checkbox|radio|color|range]`, `select`) and their wrapping labels are exempt, they have built-in press states.
- **`cursor-pointer` on every clickable element.**
- **Hover:** a subtle background step on list items and icon buttons, plus a border step when the element has a border.
- **Disabled: `disabled:opacity-50 disabled:cursor-not-allowed`.**
- **Duration: `duration-150` or `duration-200`.** Nothing else.
- **Inputs, textareas, and selects carry the project's focus pattern plus `transition-all duration-200`.** The transition is non-negotiable, without it the focus ring snaps in abruptly. Apply on every focusable control, including ones inside modals and inline editors. Never use a weaker variant of the ring than the declared one.
- **Button and control height comes from the `size` prop, never an `h-*` override.** Two tiers, nothing in between: the in-app default for every button, select, and input on an app surface, and one larger tier for the single primary CTA on a dedicated auth or onboarding screen and a modal's primary action. A dense tier exists for table-row inline actions and chips only. Marketing and landing heroes are the one place a custom height is allowed.
- **An open trigger keeps its hover state.** Any element that opens a dropdown, select, popover, or menu pairs every `hover:bg-*` with the matching `aria-expanded:` class. A trigger that visually lets go while its menu is open is a bug.
- **Icon-only or otherwise ambiguous controls get a tooltip.** A control whose outcome is not obvious from its label gets one too. Do not tooltip controls that already show a text label.
- **Keyboard shortcuts render inline on frequently used primary actions,** in small muted mono text.
- **Tooltip copy is at most ~60 chars,** formatted `"Action (Shortcut)"` or `"Label, brief description"`. Never a paragraph.
- **Images:** every `<img>` gets `select-none` in its className and `draggable={false}`.

### Destructive and mutating actions

- **Consequential record actions confirm first.** Delete, remove, revoke, duplicate, and resend open a confirm dialog with a title naming the specific record and a one-line consequence. Never fire on first click. This holds everywhere, including inside popovers, menus, and pickers. Render the confirm dialog at the component root alongside the popover, never inside popover content (which unmounts on close), and close the popover when the dialog opens so focus is not trapped. Nothing destructive or irreversible happens from a single click anywhere in the app.
- **Confirm dialogs act first, close after.** A raw Radix `AlertDialogAction` is a Close button, it dismisses before the mutation runs. Never use it directly for a mutation. Pass the mutation's `isPending` as `pending`, disable both buttons and block dismissal while pending, and close only in `onSuccess`. On error the dialog stays open and the failure toasts. A dialog that visually closes while its action is still running is a bug.
- **Mutations are never silent, they are user-driven.** An edit persists only through an explicit dirty-gated save or equivalent confirm, never automatically on change. The app never deletes, edits, or sends on the user's behalf without the user asking in that moment. AI-proposed writes go further: every assistant write tool needs approval, the model proposes and the user confirms.
- **Keep actions disabled until they are actionable.** A create needs its required fields, an edit needs a real change, a bulk action needs a selection. Dirty-track current values against the loaded record and disable when identical. For rich editors, compare a normalized saved shape (`toSavedShape(form)` mirroring exactly what the backend persists, trimmed strings, empty rows dropped) against `toSavedShape(loaded)`, so save lights up on every meaningful edit and converges back to disabled after saving. Never leave a save enabled when it would be a no-op.
- **Push an undo snapshot before any destructive bulk mutation** in editor-style apps (clear, regenerate, import, resize).
- **Confirmations only when there is something to lose.** Cheap-to-reverse actions (switching tools, zooming, navigating) never prompt.
- **Direct-manipulation mutations are optimistic.** Checkbox and toggle actions patch the query cache in `onMutate`, roll back in `onError`, and reconcile once when the last concurrent mutation settles. Never disable the control or wait for a refetch.

### Modals, popovers, overlays

- **Render every modal at the parent or page level,** never inside the working component.
- **Modals close on Escape and on backdrop click.**
- **Modals never overflow short screens and their chrome stays pinned.** The dialog scrolls via an inner wrapper capped at `max-h-[calc(100svh-4rem)]`, with a `sticky top-0` header and a `sticky bottom-0` footer on the surface background, so the body scrolls between a static header and a static action row and the close button stays reachable. Every modal action row is a real `DialogFooter` with a top border, never a plain div, or it scrolls away with the form. Short confirm boxes keep the simple cap with `overflow-y-auto`. No per-modal height caps unless an inner region needs its own scroll area.
- **Popovers inside dialogs need `modal` on the popover root.** The dialog's scroll lock blocks wheel and touch on portaled popover content, so a scrollable list inside it silently will not scroll.
- **Popovers near a screen edge get `collisionPadding={12}`.**

### Layout and polish

- **Rounded containers clip their children.** Any `rounded-md` or larger bordered container whose direct children paint full-bleed fills (row hovers, selected states) carries `overflow-hidden`, or square corners poke past the radius. Padded cards and self-rounded rows are exempt.
- **Do not stack padding on a padded primitive.** If a `Card` already applies vertical padding and its content slot the horizontal, passing `p-4` doubles it. Use `gap-*` for internal rhythm.
- **Page width comes from one shared constant,** not a per-page `max-w-*`. Both the page header bar and the body use it so widths line up. Compose extra layout with a template string. Changing the constant reshapes every page at once.
- **Hierarchy is the first job.** One clear focal point per surface and a deliberate top-to-bottom scale: hero, section heading, item title, meta. A title and its sub-items must never read at the same visual weight.
- **Visual weight matches importance.** The thing the page exists to communicate is never the quietest element on it.
- **One treatment per meaning.** A value renders through the same component everywhere. If the same thing can render two ways, they will diverge.
- **Consistent spacing rhythm, and no empty voids.** One rhythm across sections, not ad-hoc gaps. A section with two items must not leave a hollow half. Balance the grid or constrain the width.
- **Accent with restraint.** Spend a brand accent on one expressive moment per surface, not on every element. Overusing it reads cheap.
- **Scroll the one intended container.** Never `scrollIntoView` from custom navigation UI, it scrolls every ancestor and shifts the page. Compute the offset and `scrollTo` on the specific scroller.
- **Third-party UI does not theme itself.** When adding a library surface (toasts, charts, pickers), wire it to the theme or map its colors to tokens, and check it in dark before calling it done.
- **Real photos beat letter circles.** Render the image when one is available. The fallback initial circle uses a dedicated avatar surface token, never a raw hover gray.

### Loading and feedback

- **Never render a "Loading…" string.** Use a skeleton shaped like the content that is arriving (table rows, board lanes, card lines).
- **Toasts are mounted once and driven centrally.** Every mutation failure auto-toasts the backend error via the query client's mutation cache. Success toasts are opt-in per mutation via `meta`. Do not scatter `toast.*` calls through components. Skip success toasts on direct-manipulation actions that are their own feedback (drag, toggle, send).

### Shared primitives

Never hand-roll something the project already has. Reach for the shared component, and if it does not exist yet, add it there rather than improvising locally:

- Copy-to-clipboard, avatar and logo upload, date picker (never a native `<input type="date">`), max-width wrapper, modal shell, toaster, skeleton, tooltip, confirm dialog, status dot.
- If the project uses a component library, **never hand-roll a primitive it provides.** No raw `<button>`, `<input>`, `<table>`, or a `div` styled to look like a card. If a component is not installed yet, install it.

---

## React and Next.js

- **Functional components, named exports.** No default exports except where the framework requires one (Next.js pages, layouts, route handlers).
- **Server components are the default.** Add `"use client"` only on interactive leaves. Never turn a whole route into a client component to use one hook, and never accidentally convert a server component by importing a client-only module into it.
- **`next/dynamic` with `{ ssr: false }`** for client-only heavy visualizations.
- **Prefer separate components over heavy branching** when behavior differs by context (admin versus public, editor versus viewer). One component with many branches accidentally pulls context-only hooks into places they do not belong.
- **Shared UI is context-agnostic.** Data comes in as props, persistence goes out as callback props. A shared component never calls a context hook that only exists on one surface.
- **A live preview and its public page share one presentational component,** so they cannot drift.
- **Tabs and drill-in sections live in the URL** (`?tab=`, `?section=`), never in bare component state, so reloads and shared links land in the right place.
- **Deep links use the param the page actually reads.** Grep the target view's `useSearchParams` key before emitting a link. Never invent a param name.
- **Never call `setState` during render.** Use `useEffect` to initialize derived state from fetched data.
- **Do not rely on no-op providers to satisfy types.** They mask real bugs.
- **Refs for transient interaction state** (drag, hover, selection start), never React state. Never read `ref.current` during render, write in effects and read in events.
- **Do not prop-drill through a store.** Read from the store in the component or handler that needs it.

## Data fetching

### Fetch what you render, not what you discard

Endpoints and hooks are shaped around what their consumers actually use. The recurring anti-pattern is fetching a rich list or full payload just so a tiny derivation runs on the client. It looks fine in isolation and ships 50 to 200 KB on every page that mounts the consumer, plus the server work to assemble something about to be thrown away.

1. **List-to-count.** Never fetch a full collection to read `.length` or `.filter(...).length`. If a sidebar badge needs a count, build a count endpoint backed by `count(*) FILTER (...)`. Reserve the list endpoint for surfaces that render rows.
2. **Payload-for-one-field.** Never fetch a rich object when the only consumer reads one boolean. Build a status-only endpoint returning the boolean plus a few cheap scalars, and keep the rich payload behind a separate hook.

How to do it:

- One hook per intent, not per data source. `useXxxStatus` and `useXxx` are different hooks with different query keys even when they hit the same table.
- Do not paper over the waste with `select`. If a `select` callback discards 90% of the response, split the endpoint instead of being clever in the client.
- The only exception is a page that genuinely renders the full list and wants a derived count on that same surface. A badge in a sibling nav does not count as the same surface.

### React Query

- **Always wrap in a custom hook. Never call `useQuery` or `useMutation` directly in a component.**
- Stable array query keys. Set `enabled` when inputs are not ready.
- Avoid duplicate fetches. Never call a session-bound query from a component that can render on a public route.

### Boundaries

- **Public surfaces never call authenticated-only endpoints.** Public rendering uses server-fetched data plus props or a public provider. Never import an admin hook or provider into a public route.
- **Separate trust boundaries do not share component trees.** Do not import one audience's components into another's. Only context-agnostic primitives are shared.
- **Every authenticated route renders behind a single declared guard,** not ad-hoc checks scattered through components.
- **Shape permission-gated responses server-side.** Never rely on the frontend to hide a field.

## Validation and schemas

- **One source of truth for API shapes** (Zod schemas or generated types), validated at the fetch boundary. No ad-hoc `fetch` with an inline cast.
- **Never trust a model's or a client's numbers, ids, or prices.** Re-validate server-side and recompute arithmetic there.

## File organization

- **kebab-case filenames.**
- One feature is one folder, with its components, hooks, and local types colocated. Promote to a shared top-level directory only when a second feature actually needs it, not preemptively.
- `lib/` holds no React. Pure functions and the API client only.
- One stylesheet. No CSS modules and no component-local CSS files unless the project already works that way.

## Build gate

- The project exposes one combined command that runs typecheck, lint, format check, and build. Run it before any push or deploy. A green run is the gate.
- Deploys are explicit. Never claim something is live because it was pushed.
