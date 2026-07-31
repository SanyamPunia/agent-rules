# AI feature rules

Opt-in. Import from a project's `CLAUDE.md` when the product ships LLM-backed features.

## The enforcement boundary

- **The model proposes. The backend decides.** The model may reason, chain tools, and draft, but every read and write goes through a permission-scoped endpoint that re-validates. That boundary is the security model. Never remove it, and never move a check into the model's prompt or schema.
- **Never trust the model's ids, numbers, or prices.** Re-validate ids against what the caller can actually see and drop the rest. Re-price every line from the real source data. Compute every total in code. Models misread minor units, so format prices before showing them to the model and never let it sum.
- **Re-validate model-produced query documents against a whitelist** of fields, operators, and value types before executing them, then execute through the same permission-scoped service the app uses.
- **Guard the input before it reaches the provider:** a body size cap, a MIME whitelist checked against the actual bytes, and a validity check. Do this in the handler, not after the provider call.

## Writes

- **Every write tool requires approval.** The model proposes and the user confirms a card before anything mutates. The app never deletes, edits, or sends on a user's behalf without the user asking in that moment.
- **Reads execute freely.** The permission scope is the gate, not a confirmation prompt.

## Tool coverage

- **The read-tool surface is a superset of the app's read surface, per permission.** If a signed-in user can see a field, record, relationship, or config value in the UI, a read tool must retrieve it. Any legitimate in-scope question must be answerable by composing tools. Coverage, not the security model, is what makes an assistant feel general rather than brittle.
- **Ship a tool with the feature.** When you add anything a user can read, add or widen the matching read tool in the same change, the way you add a nav item. A new field on an entity a tool already covers means widening that tool's response, not leaving it dropped.
- **Mirror the endpoint's gate exactly.** A tool's required permissions equal the permissions of the route it wraps. No looser, which leaks. No tighter, which hides data the user can already see.
- **Discovery then detail.** A `queryX` list or search tool to find records by name, plus a `getX(id)` detail tool returning the full record the caller can see.
- **Describe tools richly.** The description and usage guidance are the single biggest driver of whether the model picks the right tool. Say what it returns, when to use it, and how it composes with others.

## Providers

- **Wrap the provider behind an interface,** with a `configured` check and a distinct not-configured error. Missing credentials must let the app boot with that one feature degraded and a clear message, never crash at startup.
- **Call the provider's REST API directly** rather than taking on an SDK dependency, unless the SDK earns its weight.
- **Resolve the provider from config in one place,** with a documented precedence order, and expose which one is active on a health endpoint.
- **Rate limit AI endpoints per user,** separately from the app's general limits, and meter spend against a cap.
- **Keep a deterministic offline path** (a heuristic or fixture mode) so the product is demoable and testable without a live key.

## Persistence

- **Chat storage is a dumb store.** Persist message parts verbatim, scope them by owner, and never interpret them server-side. Convert legacy shapes on read, not with a migration.
