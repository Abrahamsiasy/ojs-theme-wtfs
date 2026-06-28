# Issue Sidebar Custom Block

Paste the HTML below into **Settings → Website → Plugins → Custom Block Manager** (or your custom block plugin) as a sidebar block for the journal.

The theme renders sidebar blocks via the OJS `Templates::Common::Sidebar` hook on **issue view**, **archives**, and **article view** pages. Use the markup and classes exactly as shown so it matches the theme styles in `styles/pages/issue.less`, `styles/pages/issueArchive.less`, and `styles/pages/article.less`.

## Setup

1. Create a custom block (e.g. **Issue sidebar tools**).
2. Enable it for the **Sidebar** context.
3. Paste the HTML below into the block content (Source / HTML mode).
4. Replace placeholder values when you publish a new issue (cover URL, links, citation, etc.).

## Placeholders to update per issue

| Placeholder | Example |
|-------------|---------|
| Cover image URL | `/public/journals/1/cover_issue_7_en.jpg` |
| Cover alt text | `Vol. 5 No. 1 (2026): JTS` |
| Journal acronym | `JTS` |
| Issue title (mid) | `JTS` or issue title |
| Issue subtitle (zh) | `太極科學期刊` |
| Issue identification (bot) | `Vol. 5 No. 1 (2026): JTS` |
| Previous issue URL + label | link to prior issue |
| Next issue URL + label | link to newer issue (optional) |
| Archives URL | `/index.php/jts/issue/archive` |
| Citation text | full issue citation string |
| Indexed databases | one `<li>` per database name |

---

## HTML to paste

```html
<div class="javs_issue_sidebar__panel">
	<div class="javs_issue_sidebar__cover">
		<div class="javs_issue_cover javs_issue_cover--mini javs_issue_cover--photo">
			<img
				class="javs_issue_cover__img"
				src="/public/journals/1/cover_issue_7_en.jpg"
				alt="Vol. 5 No. 1 (2026): JTS"
				loading="lazy"
			>
			<span class="javs_issue_cover__overlay">
				<span class="javs_issue_cover__top">JTS</span>
				<span class="javs_issue_cover__center">
					<span class="javs_issue_cover__mid">JTS</span>
					<span class="javs_issue_cover__mid-zh">太極科學期刊</span>
				</span>
				<span class="javs_issue_cover__bot">Vol. 5 No. 1 (2026): JTS</span>
			</span>
		</div>
	</div>

	<h4>Navigate Issues</h4>
	<a href="/index.php/jts/issue/view/6" class="javs_issue_sidebar__block">
		← Previous Issue (Vol. 4 No. 2 (2025): JTS)
	</a>
	<a href="/index.php/jts/issue/archive" class="javs_issue_sidebar__block">
		View All Archives →
	</a>

	<h4 id="javsIssueCitation">Cite this Issue</h4>
	<div class="javs_issue_sidebar__citation">
		Journal of Taiji Science. (2026). JTS. Vol. 5 No. 1 (2026).
	</div>

	<h4>Indexed In</h4>
	<ul class="javs_issue_sidebar__indexed">
		<li>
			<span class="javs_issue_sidebar__indexed_icon" aria-hidden="true">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
			</span>
			CrossRef
		</li>
		<li>
			<span class="javs_issue_sidebar__indexed_icon" aria-hidden="true">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
			</span>
			Semantic Scholar
		</li>
		<li>
			<span class="javs_issue_sidebar__indexed_icon" aria-hidden="true">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
			</span>
			Google Scholar
		</li>
		<li>
			<span class="javs_issue_sidebar__indexed_icon" aria-hidden="true">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
			</span>
			Dimensions
		</li>
		<li>
			<span class="javs_issue_sidebar__indexed_icon" aria-hidden="true">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
			</span>
			BASE
		</li>
		<li>
			<span class="javs_issue_sidebar__indexed_icon" aria-hidden="true">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
			</span>
			ROAD
		</li>
		<li>
			<span class="javs_issue_sidebar__indexed_icon" aria-hidden="true">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
			</span>
			ICI World of Journals
		</li>
		<li>
			<span class="javs_issue_sidebar__indexed_icon" aria-hidden="true">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
			</span>
			EuroPub
		</li>
		<li>
			<span class="javs_issue_sidebar__indexed_icon" aria-hidden="true">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
			</span>
			SciSpace
		</li>
		<li>
			<span class="javs_issue_sidebar__indexed_icon" aria-hidden="true">
				<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
			</span>
			R Discovery
		</li>
	</ul>
</div>
```

## Notes

- **No cover image:** change `javs_issue_cover--photo` to `javs_issue_cover--placeholder` and remove the `<img>` tag; the gradient placeholder will show.
- **Next issue link:** add another `<a class="javs_issue_sidebar__block">` after the previous issue link when needed.
- **Download full issue:** optional button above “Navigate Issues”:

```html
<a href="/index.php/jts/issue/view/7/123" class="javs_btn javs_btn--primary javs_issue_sidebar__download">
	Download Full Issue (PDF)
</a>
```

- The hero **Cite this Issue** button links to `#javsIssueCitation` — keep that `id` on the citation heading above.
- Indexed list matches the **Indexed databases** theme option on the homepage; edit the `<li>` items when your list changes.

---

## Article view sidebar

On **article view** pages, the theme renders the same sidebar hook beside the article body. OJS fills the sidebar automatically with downloads, how-to-cite (if CSL plugin is enabled), issue/section info, and corresponding author.

Add optional custom blocks (metrics, jump links, related articles) with the same panel classes:

```html
<div class="javs_issue_sidebar__panel">
	<h4>Jump to</h4>
	<nav class="javs_article_jump">
		<a href="#abstract">Abstract</a>
		<a href="#references">References</a>
	</nav>
</div>
```

Style jump links in your block with plain `<a>` tags inside `.javs_issue_sidebar__panel`; anchor targets must match `id` attributes in the article body (`#abstract`, `#references`, `#author-bios`, etc.).
