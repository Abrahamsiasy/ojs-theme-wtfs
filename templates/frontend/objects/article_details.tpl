{**
 * plugins/themes/custom/templates/frontend/objects/article_details.tpl
 *
 * WTSF-style article detail — header band, main column, OJS sidebar + custom blocks.
 *}
{if !$heading}
	{assign var="heading" value="h3"}
{/if}

{assign var=articleAuthors value=$javs.authorsDisplay.authors|default:[]}
{assign var=articleAffiliations value=$javs.authorsDisplay.affiliations|default:[]}
{assign var=articleCitations value=$parsedCitations|default:[]}
{assign var=articlePrimaryGalleys value=$primaryGalleys|default:[]}

<article class="obj_article_details javs_article">

	{if $publication->getData('status') !== PKP\submission\PKPSubmission::STATUS_PUBLISHED}
		<div class="javs_article_container">
			<div class="cmp_notification notice">
				{capture assign="submissionUrl"}{url page="dashboard" op="editorial" workflowSubmissionId=$article->getId()}{/capture}
				{translate key="submission.viewingPreview" url=$submissionUrl}
			</div>
		</div>
	{elseif $currentPublication->getId() !== $publication->getId()}
		<div class="javs_article_container">
			<div class="cmp_notification notice">
				{capture assign="latestVersionUrl"}{url page="article" op="view" path=$article->getBestId()}{/capture}
				{translate key="submission.outdatedVersion"
					datePublished=$publication->getData('datePublished')|date_format:$dateFormatShort
					urlRecentVersion=$latestVersionUrl|escape
				}
			</div>
		</div>
	{/if}

	<header class="javs_article_header">
		<div class="javs_article_container">
			{if $section}
				<span class="javs_tag javs_tag--type">{$section->getLocalizedTitle()|escape}</span>
			{/if}

			<h1 class="javs_article_title">
				{$publication->getLocalizedTitle(null, 'html')|strip_unsafe_html}
			</h1>

			{if $publication->getLocalizedData('subtitle')}
				<p class="javs_article_subtitle">
					{$publication->getLocalizedSubTitle(null, 'html')|strip_unsafe_html}
				</p>
			{/if}

			{if $articleAuthors|@count}
				<div class="javs_article_authors_line">
					{foreach from=$articleAuthors item=authorLine name=authorLines}
						<span class="javs_article_author">
							{$authorLine.name|escape}
							{foreach from=$authorLine.affiliationIndices item=affIdx}
								<sup>{$affIdx}</sup>
							{/foreach}
						</span>
						{if !$smarty.foreach.authorLines.last}
							<span class="javs_article_authors_sep" aria-hidden="true">·</span>
						{/if}
					{/foreach}
				</div>
			{/if}

			{if $articleAffiliations|@count}
				<div class="javs_article_affiliations">
					{foreach from=$articleAffiliations item=affiliation name=affiliations}
						<div class="javs_article_affiliation">
							<sup>{$smarty.foreach.affiliations.iteration}</sup>
							{$affiliation|escape}
						</div>
					{/foreach}
				</div>
			{/if}

			{assign var=doiObject value=$article->getCurrentPublication()->getData('doiObject')}
			{if $doiObject}
				{assign var="doiUrl" value=$doiObject->getData('resolvingUrl')|escape}
				<div class="javs_article_doi">
					<span class="javs_article_doi__label">{translate key="doi.readerDisplayName"}:</span>
					<a href="{$doiUrl}" class="javs_article_doi__link">{$doiObject->getDoi()|escape}</a>
					<button type="button" class="javs_article_doi__copy" data-javs-copy-doi="{$doiObject->getDoi()|escape}" title="{translate key="common.copy"}">
						<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
						<span class="pkp_screen_reader">{translate key="common.copy"}</span>
					</button>
				</div>
			{/if}

			{if $articlePrimaryGalleys|@count}
				<div class="javs_article_actions">
					{foreach from=$articlePrimaryGalleys item=galley name=primaryGalleys}
						{include file="frontend/objects/galley_link.tpl"
							parent=$article
							publication=$publication
							galley=$galley
							purchaseFee=$currentJournal->getData('purchaseArticleFee')
							purchaseCurrency=$currentJournal->getData('currency')
							labelledBy="javsGalleyBtn{$smarty.foreach.primaryGalleys.iteration}"
						}
					{/foreach}
				</div>
			{/if}

			{if $publication->getData('datePublished') || $publication->getData('pages') || $issue}
				<div class="javs_article_meta_strip">
					{if $publication->getData('datePublished')}
						<div>
							<strong>{translate key="submissions.published"}:</strong>
							{if $firstPublication->getId() === $publication->getId()}
								{$firstPublication->getData('datePublished')|date_format:$dateFormatShort}
							{else}
								{translate key="submission.updatedOn"
									datePublished=$firstPublication->getData('datePublished')|date_format:$dateFormatShort
									dateUpdated=$publication->getData('datePublished')|date_format:$dateFormatShort
								}
							{/if}
						</div>
					{/if}
					{if $issue}
						<div>
							<strong>{translate key="issue.issue"}:</strong>
							<a href="{url page="issue" op="view" path=$issue->getBestIssueId()}">{$issue->getIssueIdentification()|escape}</a>
						</div>
					{/if}
					{if $publication->getData('pages')}
						<div>
							<strong>{translate key="editor.issues.pages"}:</strong>
							{$publication->getData('pages')|escape}
						</div>
					{/if}
				</div>
			{/if}
		</div>
	</header>

	<section class="javs_article_section">
		<div class="javs_article_with_sidebar">
			<div class="javs_article_with_sidebar__main">
				<div class="javs_article_body">

					{if $publication->getLocalizedData('abstract')}
						<div class="javs_article_abstract" id="abstract">
							<h2>{translate key="article.abstract"}</h2>
							{$publication->getLocalizedData('abstract')|strip_unsafe_html}
						</div>
					{/if}

					{if !empty($publication->getLocalizedData('keywords'))}
						<div class="javs_article_keywords">
							{foreach name="keywords" from=$publication->getLocalizedData('keywords') item="keyword"}
								<span>{$keyword.name|escape}</span>
							{/foreach}
						</div>
					{/if}

					{call_hook name="Templates::Article::Main"}

					{if $activeTheme && $activeTheme->getOption('displayStats') != 'none'}
						{$activeTheme->displayUsageStatsGraph($article->getId())}
						<section class="javs_article_panel" id="downloads">
							<h2>{translate key="plugins.themes.default.displayStats.downloads"}</h2>
							<canvas class="usageStatsGraph" data-object-type="Submission" data-object-id="{$article->getId()|escape}"></canvas>
							<div class="usageStatsUnavailable" data-object-type="Submission" data-object-id="{$article->getId()|escape}">
								{translate key="plugins.themes.default.displayStats.noStats"}
							</div>
						</section>
					{/if}

					{assign var="hasBiographies" value=0}
					{assign var=publicationAuthors value=$publication->getData('authors')|default:[]}
					{foreach from=$publicationAuthors item=author}
						{if $author->getLocalizedData('biography')}
							{assign var="hasBiographies" value=$hasBiographies+1}
						{/if}
					{/foreach}
					{if $hasBiographies}
						<section class="javs_article_panel" id="author-bios">
							<h2>
								{if $hasBiographies > 1}
									{translate key="submission.authorBiographies"}
								{else}
									{translate key="submission.authorBiography"}
								{/if}
							</h2>
							<ul class="javs_article_bios">
								{foreach from=$publicationAuthors item=author}
									{if $author->getLocalizedData('biography')}
										<li class="javs_article_bio">
											<div class="javs_article_bio__name">
												{if $author->getLocalizedAffiliationNamesAsString()}
													{capture assign="authorName"}{$author->getFullName()|escape}{/capture}
													{capture assign="authorAffiliations"} {$author->getLocalizedAffiliationNamesAsString(null, ', ')|escape} {/capture}
													{translate key="submission.authorWithAffiliation" name=$authorName affiliation=$authorAffiliations}
												{else}
													{$author->getFullName()|escape}
												{/if}
											</div>
											<div class="javs_article_bio__text">
												{$author->getLocalizedData('biography')|strip_unsafe_html}
											</div>
										</li>
									{/if}
								{/foreach}
							</ul>
						</section>
					{/if}

					{if $articleCitations|@count || (string) $publication->getData('citationsRaw')}
						<section class="javs_article_references" id="references">
							<h2>{translate key="submission.citations"}</h2>
							{if $articleCitations|@count}
								<ol>
									{foreach from=$articleCitations item="parsedCitation"}
										<li>{$parsedCitation->getCitationWithLinks()|strip_unsafe_html} {call_hook name="Templates::Article::Details::Reference" citation=$parsedCitation}</li>
									{/foreach}
								</ol>
							{else}
								<div class="javs_article_references__raw">
									{$publication->getData('citationsRaw')|escape|nl2br}
								</div>
							{/if}
						</section>
					{/if}

					{if $publication->getLocalizedData('dataAvailability')}
						<section class="javs_article_panel" id="data-availability">
							<h2>{translate key="submission.dataAvailability"}</h2>
							{$publication->getLocalizedData('dataAvailability')|strip_unsafe_html}
						</section>
					{/if}

					<div class="javs_article_plugins">
						{call_hook name="Templates::Article::Footer::PageFooter"}
					</div>

				</div>
			</div>

			<aside class="javs_article_sidebar" aria-label="{translate key="common.navigation.sidebar"}">
				{include file="frontend/pages/article/sidebar_ojs.tpl"}

				{if $javsArticleSidebar}
					<div class="javs_issue_sidebar__blocks">
						{$javsArticleSidebar}
					</div>
				{/if}
			</aside>
		</div>
	</section>

</article>
