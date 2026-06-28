{**
 * plugins/themes/custom/templates/frontend/pages/indexJournal.tpl
 *
 * WTSF-style journal homepage — dynamic OJS data with theme colours.
 *}
{include file="frontend/components/header.tpl" pageTitleTranslated=$currentJournal->getLocalizedName()}

{assign var=javs value=$javsHomepage|default:[]}
{assign var=isFullWidth value=true}
{capture assign=javsHomeSidebar}{call_hook name="Templates::Common::Sidebar"}{/capture}

<div class="page_index_journal javs_home">

	{call_hook name="Templates::Index::journal"}

	{* ── Hero ── *}
	<section class="javs_home_hero javs_home_section--full">
		<div class="javs_home_container javs_home_hero__grid">
			<div class="javs_home_hero__copy">
				{if $javs.eyebrow}
					<div class="javs_home_eyebrow">{$javs.eyebrow|escape}</div>
				{/if}
				<h2 class="javs_home_hero__title">{$javs.heroTagline|escape}</h2>
				{if $javs.heroSecondaryTitle && $javs.heroSecondaryTitle != $javs.heroTagline}
					<div class="javs_home_hero__zh">{$javs.heroSecondaryTitle|escape}</div>
				{/if}
				{if $javs.heroSubtitle && $javs.heroSubtitle != $javs.heroTagline}
					<p class="javs_home_hero__subhead">{$javs.heroSubtitle|escape}</p>
				{/if}
				<div class="javs_home_hero__actions">
					{if $issue}
						<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="view" path=$issue->getBestIssueId()}" class="javs_btn javs_btn--light">
							{translate key="plugins.themes.custom.homepage.browseCurrentIssue"} →
						</a>
					{/if}
					{if !$currentContext->getData('disableSubmissions')}
						<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="submissions"}" class="javs_btn javs_btn--secondary">
							{translate key="about.submissions"}
						</a>
					{/if}
				</div>
			</div>

			{if $javs.featuredArticle}
				{assign var=feat value=$javs.featuredArticle}
				{assign var=featPub value=$feat.publication}
				{assign var=featPath value=$featPub->getData('urlPath')|default:$feat.submission->getId()}
				<aside class="javs_home_featured">
					<div class="javs_home_featured__label">{translate key="plugins.themes.custom.homepage.featuredArticle"}</div>
					<div class="javs_home_featured__cover">{$feat.issueIdentification|escape}</div>
					<h3 class="javs_home_featured__title">
						<a href="{url page="article" op="view" path=$featPath}">
							{$featPub->getLocalizedTitle(null, 'html')|strip_unsafe_html}
						</a>
					</h3>
					<div class="javs_home_featured__authors">
						{$featPub->getAuthorString($javs.authorUserGroups)|escape}
					</div>
					<a href="{url page="article" op="view" path=$featPath}" class="javs_home_featured__read">
						{translate key="plugins.themes.custom.homepage.readArticle"} →
					</a>
				</aside>
			{/if}
		</div>
	</section>

	{* ── Stats ── *}
	<section class="javs_home_stats javs_home_section--full">
		<div class="javs_home_container">
			<div class="javs_home_stats__grid">
				<div class="javs_home_stat">
					<div class="javs_home_stat__num">{$javs.publishedCount|escape}+</div>
					<div class="javs_home_stat__lbl">{translate key="plugins.themes.custom.homepage.stats.articles"}</div>
				</div>
				<div class="javs_home_stat">
					<div class="javs_home_stat__num">{$javs.indexedCount|escape}+</div>
					<div class="javs_home_stat__lbl">{translate key="plugins.themes.custom.homepage.stats.indexing"}</div>
				</div>
				<div class="javs_home_stat">
					<div class="javs_home_stat__num">{$javs.statsReviewTime|escape}</div>
					<div class="javs_home_stat__lbl">{translate key="plugins.themes.custom.homepage.stats.reviewTime"}</div>
				</div>
				{if $javs.firstPublishedYear}
					<div class="javs_home_stat">
						<div class="javs_home_stat__num">{$javs.firstPublishedYear|escape}</div>
						<div class="javs_home_stat__lbl">{translate key="plugins.themes.custom.homepage.stats.openAccessSince"}</div>
					</div>
				{/if}
			</div>
		</div>
	</section>

	{* Cream sections share a right sidebar column (custom blocks) — not full-page middle placement *}
	{if $javsHomeSidebar}
		<div class="javs_home_with_sidebar">
			<div class="javs_home_with_sidebar__main">
	{/if}

	{* ── Current Issue ── *}
	{if $issue && $publishedSubmissions && is_array($publishedSubmissions)}
		<section class="javs_home_section javs_home_section--cream">
			<div class="javs_home_container">
				<div class="javs_home_section_head">
					<h2>{translate key="journal.currentIssue"}</h2>
					<p>{translate key="plugins.themes.custom.homepage.currentIssueLead"}</p>
				</div>
				<div class="javs_home_current_issue">
					<div class="javs_home_current_issue__cover_col">
						{assign var=issueCover value=$issue->getLocalizedCoverImageUrl()}
						{assign var=javsCoverAcronym value=$currentJournal->getLocalizedData('acronym')|default:$currentJournal->getLocalizedName()}
						{if $issue->getLocalizedTitle()}
							{assign var=javsCoverMid value=$issue->getLocalizedTitle()}
						{else}
							{assign var=javsCoverMid value=$currentJournal->getLocalizedName()}
						{/if}
						{assign var=javsCoverSub value=""}
						{if $currentLocale == 'zh_Hans'}
							{assign var=javsCoverSub value=$currentJournal->getLocalizedName('en')}
						{elseif $currentJournal->getLocalizedName('zh_Hans')}
							{assign var=javsCoverSub value=$currentJournal->getLocalizedName('zh_Hans')}
						{/if}
						{if $javsCoverSub == $javsCoverMid}{assign var=javsCoverSub value=""}{/if}
						{capture assign=javsCoverAlt}
							{translate key="issue.viewIssueIdentification" identification=$issue->getIssueIdentification()|escape}
						{/capture}

						<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="view" path=$issue->getBestIssueId()}"
							class="javs_home_issue_cover{if $issueCover} javs_home_issue_cover--photo{else} javs_home_issue_cover--placeholder{/if}">
							{if $issueCover}
								<img
									class="javs_home_issue_cover__img"
									src="{$issueCover|escape}"
									alt="{$issue->getLocalizedCoverImageAltText()|escape|default:$javsCoverAlt}"
									loading="lazy"
								>
							{/if}
							<span class="javs_home_issue_cover__overlay">
								<span class="javs_home_issue_cover__top">{$javsCoverAcronym|escape}</span>
								<span class="javs_home_issue_cover__center">
									<span class="javs_home_issue_cover__mid">{$javsCoverMid|escape}</span>
									{if $javsCoverSub}
										<span class="javs_home_issue_cover__mid-zh">{$javsCoverSub|escape}</span>
									{/if}
								</span>
								<span class="javs_home_issue_cover__bot">{$issue->getIssueIdentification()|escape}</span>
							</span>
						</a>

						<div class="javs_home_issue_meta">
							<div class="javs_home_issue_meta__vol">{$issue->getIssueIdentification()|escape}</div>
							<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="view" path=$issue->getBestIssueId()}">
								{translate key="plugins.themes.custom.homepage.viewFullIssue"} →
							</a>
						</div>
					</div>
					<ul class="javs_home_toc">
						{foreach from=$publishedSubmissions item=section}
							{foreach from=$section.articles item=article}
								{assign var=publication value=$article->getCurrentPublication()}
								{assign var=articlePath value=$publication->getData('urlPath')|default:$article->getId()}
								<li class="javs_home_toc__item">
									{if $section.title}
										<span class="javs_home_pill">{$section.title|escape}</span>
									{/if}
									<h4>
										<a href="{url page="article" op="view" path=$articlePath}">
											{$publication->getLocalizedTitle(null, 'html')|strip_unsafe_html}
										</a>
									</h4>
									<div class="javs_home_toc__authors">
										{$publication->getAuthorString($authorUserGroups)|escape}
									</div>
									{assign var=tocDoiObject value=$publication->getData('doiObject')}
									{if $tocDoiObject}
										{assign var=tocDoiUrl value=$tocDoiObject->getData('resolvingUrl')|escape}
										<div class="javs_home_toc__doi">
											<span class="javs_home_toc__doi-label">{translate key="doi.readerDisplayName"}:</span>
											<a href="{$tocDoiUrl}" class="javs_home_toc__doi-link">{$tocDoiObject->getDoi()|escape}</a>
										</div>
									{/if}
								</li>
							{/foreach}
						{/foreach}
					</ul>
				</div>
			</div>
		</section>
	{/if}

	{* ── Recently Published ── *}
	{if $javs.recentArticles && is_array($javs.recentArticles) && $javs.recentArticles|@count}
		<section class="javs_home_section javs_home_section--cream">
			<div class="javs_home_container">
				<div class="javs_home_section_head">
					<h2>{translate key="plugins.themes.custom.homepage.recentlyPublished"}</h2>
					<p>{translate key="plugins.themes.custom.homepage.recentlyPublishedLead" numIssues=$javs.issueCount}</p>
				</div>
				<div class="javs_home_article_grid">
					{foreach from=$javs.recentArticles item=article}
						{include file="frontend/pages/home/article_card.tpl" article=$article authorUserGroups=$javs.authorUserGroups}
					{/foreach}
				</div>
				{if $javs.recentArticlesHasMore}
				<div class="javs_home_center javs_home_center--spaced">
					<button
						type="button"
						class="javs_btn javs_btn--outline"
						data-javs-load-more-articles
						data-load-url="{url page="javsHome" op="recentArticles"|escape}"
						data-offset="{$javs.recentArticlesNextOffset|escape}"
						data-label="{translate key="plugins.themes.custom.homepage.loadMoreArticles"|escape}"
						data-loading-label="{translate key="plugins.themes.custom.homepage.loadMoreArticles.loading"|escape}"
					>
						{translate key="plugins.themes.custom.homepage.loadMoreArticles"} →
					</button>
				</div>
				{/if}
			</div>
		</section>
	{/if}

	{* ── Editorial Team ── *}
	{if $javs.mastheadPreview && is_array($javs.mastheadPreview) && $javs.mastheadPreview|@count}
		<section class="javs_home_section javs_home_section--cream">
			<div class="javs_home_container">
				<div class="javs_home_section_head">
					<h2>{translate key="common.editorialMasthead"}</h2>
				</div>
				<div class="javs_home_editors">
					{foreach from=$javs.mastheadPreview item=editor}
						<div class="javs_home_editor">
							<div class="javs_home_editor__avatar">{$editor.initials|escape}</div>
							<h4>{$editor.user->getFullName()|escape}</h4>
							<div class="javs_home_editor__role">{$editor.role|escape}</div>
							{if $editor.user->getLocalizedData('affiliation')}
								<div class="javs_home_editor__inst">{$editor.user->getLocalizedData('affiliation')|escape}</div>
							{/if}
						</div>
					{/foreach}
				</div>
				<div class="javs_home_center">
					<a href="{url page="about" op="editorialMasthead"}" class="javs_btn javs_btn--outline">
						{translate key="plugins.themes.custom.homepage.meetEditorialTeam"} →
					</a>
				</div>
			</div>
		</section>
	{/if}

	{if $javsHomeSidebar}
			</div>
			{include file="frontend/pages/home/sidebar_blocks.tpl"}
		</div>
	{/if}

	{* ── Subject Areas (journal sections) ── *}
	{if $javs.showSubjectAreas && $javs.sections && is_array($javs.sections) && $javs.sections|@count}
		<section class="javs_home_section">
			<div class="javs_home_container">
				<div class="javs_home_section_head">
					<h2>{translate key="plugins.themes.custom.homepage.subjectAreas"}</h2>
					<p>{translate key="plugins.themes.custom.homepage.subjectAreasLead"}</p>
				</div>
				<div class="javs_home_subject_grid">
					{foreach from=$javs.sections item=section name=sections}
						<div class="javs_home_subject_card">
							<div class="javs_home_subject_icon" aria-hidden="true">
								<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><circle cx="12" cy="12" r="3"/><path d="M12 1v6M12 17v6M4.22 4.22l4.24 4.24M15.54 15.54l4.24 4.24M1 12h6M17 12h6"/></svg>
							</div>
							<h3>{$section->getLocalizedTitle()|escape}</h3>
						</div>
					{/foreach}
				</div>
			</div>
		</section>
	{/if}

	{* ── Indexed In ── *}
	{if $javs.indexedDatabases && is_array($javs.indexedDatabases) && $javs.indexedDatabases|@count}
		<section class="javs_home_section javs_home_section--full javs_home_indexed">
			<div class="javs_home_container">
				<div class="javs_home_section_head javs_home_section_head--center">
					<h2>{translate key="plugins.themes.custom.homepage.indexedIn"}</h2>
					<p>{translate key="plugins.themes.custom.homepage.indexedInLead"}</p>
				</div>
				<div class="javs_home_indexed_grid">
					{foreach from=$javs.indexedDatabases item=db}
						{if $db.url}
							<a href="{$db.url|escape}" class="javs_home_indexed_item" target="_blank" rel="noopener noreferrer">
						{else}
							<div class="javs_home_indexed_item">
						{/if}
							<span class="javs_home_indexed_item__logo">
								<img
									src="{$db.logoUrl|escape}"
									alt=""
									width="48"
									height="48"
									loading="lazy"
								>
							</span>
							<span class="javs_home_indexed_item__name">{$db.name|escape}</span>
						{if $db.url}
							</a>
						{else}
							</div>
						{/if}
					{/foreach}
				</div>
			</div>
		</section>
	{/if}

	{* ── Why Publish ── *}
	<section class="javs_home_section">
		<div class="javs_home_container">
			<div class="javs_home_section_head">
				<h2>{translate key="plugins.themes.custom.homepage.whyPublish" journalName=$currentJournal->getLocalizedName()|escape}</h2>
			</div>
			<div class="javs_home_why_grid">
				<div class="javs_home_why_col">
					<div class="javs_home_why_icon" aria-hidden="true">
						<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><circle cx="12" cy="12" r="10"/><path d="M2 12h20M12 2a15 15 0 010 20M12 2a15 15 0 000 20"/></svg>
					</div>
					<h3>{translate key="plugins.themes.custom.homepage.why.global.title"}</h3>
					<p>{translate key="plugins.themes.custom.homepage.why.global.text" numLocales=$javs.supportedLocaleCount numIndexed=$javs.indexedCount}</p>
				</div>
				<div class="javs_home_why_col">
					<div class="javs_home_why_icon" aria-hidden="true">
						<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
					</div>
					<h3>{translate key="plugins.themes.custom.homepage.why.review.title"}</h3>
					<p>{translate key="plugins.themes.custom.homepage.why.review.text" reviewTime=$javs.statsReviewTime|escape}</p>
				</div>
				<div class="javs_home_why_col">
					<div class="javs_home_why_icon" aria-hidden="true">
						<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M4 6h16M4 12h10M4 18h16"/></svg>
					</div>
					<h3>{translate key="plugins.themes.custom.homepage.why.doi.title"}</h3>
					<p>{if $javs.doiPrefix}{translate key="plugins.themes.custom.homepage.why.doi.text" doiPrefix=$javs.doiPrefix|escape}{else}{translate key="plugins.themes.custom.homepage.why.doi.textGeneric"}{/if}</p>
				</div>
			</div>
		</div>
	</section>

	{* ── Announcements ── *}
	{if $numAnnouncementsHomepage && $announcements|@count}
		<section class="javs_home_section javs_home_section--full javs_home_announcements">
			<div class="javs_home_container">
				<div class="javs_home_section_head">
					<h2>{translate key="announcement.announcements"}</h2>
					<p>{translate key="plugins.themes.custom.homepage.announcementsLead"}</p>
				</div>
				<div class="javs_home_ann_grid">
					{foreach name=anns from=$announcements item=announcement}
						{if $smarty.foreach.anns.iteration > $numAnnouncementsHomepage}{break}{/if}
						<article class="javs_home_ann_card">
							<div class="javs_home_ann_card__date">{$announcement->datePosted->format($dateFormatShort)}</div>
							<h3>
								<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="announcement" op="view" path=$announcement->id}">
									{$announcement->getLocalizedData('title')|escape}
								</a>
							</h3>
							{if $announcement->getLocalizedData('descriptionShort')}
								<p>{$announcement->getLocalizedData('descriptionShort')|strip_unsafe_html}</p>
							{/if}
							<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="announcement" op="view" path=$announcement->id}">
								{translate key="common.readMore"} →
							</a>
						</article>
					{/foreach}
				</div>
			</div>
		</section>
	{/if}

	{* ── Additional CMS content ── *}
	{if $additionalHomeContent}
		<section class="javs_home_section">
			<div class="javs_home_container javs_home_additional">
				{$additionalHomeContent}
			</div>
		</section>
	{/if}

	{* ── CTA ── *}
	{if !$currentContext->getData('disableSubmissions')}
		<section class="javs_home_cta javs_home_section--full">
			<div class="javs_home_container">
				<h2>{translate key="plugins.themes.custom.homepage.cta.title"}</h2>
				<p>{translate key="plugins.themes.custom.homepage.cta.text"}</p>
				<a href="{url page="user" op="register"}" class="javs_btn javs_btn--cream">
					{translate key="plugins.themes.custom.homepage.cta.button"} →
				</a>
			</div>
		</section>
	{/if}

</div>

{include file="frontend/components/footer.tpl"}
