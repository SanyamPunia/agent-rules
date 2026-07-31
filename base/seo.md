# SEO and AEO rules

Opt-in. Import from a project's `CLAUDE.md`. Written for content and programmatic-SEO surfaces, not for app dashboards.

## Rendering

- **Every page is server-rendered.** A crawler must see the full content, including any live data, in the initial HTML response. No client-side fetching for anything a crawler needs to see.
- **Cache with a revalidation window rather than serving stale HTML indefinitely.** Say what the window is and why.
- **`sitemap.xml` and `robots.txt` are generated, not hand-maintained.**

## Metadata

- **Titles follow one template per page type,** filled from real data.
- **Meta descriptions are dynamic** and include the current state of the thing being described, not a generic blurb.
- **Canonical URLs and Open Graph tags on every page.**
- **Metadata and body content come from the same cached loader,** so the description cannot contradict what the page shows.

## Structured data

- **JSON-LD on every content page**, matched to the page type (`WebPage`, `FAQPage`, `Article`, `Product`).
- **Answers in structured data must be truthful and timestamped.** A `FAQPage` answer that states a live fact carries the time that fact was checked.
- **Never mark up something the page does not visibly show.**

## Content

- **Every page is genuinely unique** in its description, its body, and its data. No two pages may share identical body text outside the shared layout. Templated sections vary by category, not by find-and-replace on a name.
- **Honest timestamps everywhere.** Anything time-sensitive displays when it was last checked, in relative form with an absolute server-rendered fallback.
- **Never publish a claim you cannot verify.** When a check is inconclusive, say it is unverifiable and show what is known. A confident wrong answer destroys both credibility and citability, which is the whole asset.
- **Internal links are part of the content,** not an afterthought. Every page links to related pages in its cluster.
