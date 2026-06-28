{**
 * Issue hero — cover + metadata (WTSF issue.html)
 *}
{assign var=issueTitle value=$issue->getLocalizedTitle()|default:$currentJournal->getLocalizedName()}

<section class="javs_issue_hero javs_issue_section javs_issue_section--cream">
	{if !$javsIssueInSidebarGrid}
		<div class="javs_issue_container">
	{/if}
	<div class="javs_issue_hero__grid">
		<div class="javs_issue_hero__cover_col">
			{include file="frontend/pages/issue/cover.tpl" variant="hero" linked=false}
		</div>
		<div class="javs_issue_hero__info">
			<div class="javs_issue_eyebrow">{$issueSeries|default:$issueIdentification|escape}</div>
			<h1>{$issueTitle|escape}</h1>
			<div class="javs_issue_hero__meta">
				{if $includeIssuePublishDate && $issue->getDatePublished()}
					{translate key="plugins.themes.custom.issue.published" date=$issue->getDatePublished()|date_format:$dateFormatShort}
				{/if}
				{if $javs.articleCount}
					<span class="javs_issue_hero__meta_sep">·</span>
					{translate key="plugins.themes.custom.issue.articleCount" numArticles=$javs.articleCount}
				{/if}
				{if $javs.pageRange}
					<span class="javs_issue_hero__meta_sep">·</span>
					{translate key="plugins.themes.custom.issue.pageRange" pages=$javs.pageRange|escape}
				{/if}
			</div>
			{if $issue->hasDescription()}
				<div class="javs_issue_hero__blurb">
					{$issue->getLocalizedDescription()|strip_unsafe_html}
				</div>
			{/if}
			<div class="javs_issue_hero__actions">
				{if $issueGalleys|@count}
					{foreach from=$issueGalleys item=galley name=issueGalleys}
						{if $smarty.foreach.issueGalleys.first}
							<a href="{url page="issue" op="view" path=$issue->getBestIssueId()|to_array:$galley->getBestGalleyId()}"
								class="javs_btn javs_btn--primary">
								{translate key="plugins.themes.custom.issue.downloadFullIssue" label=$galley->getGalleyLabel()|escape}
							</a>
						{/if}
					{/foreach}
				{/if}
				<a href="#javsIssueCitation" class="javs_btn javs_btn--outline">
					{translate key="plugins.themes.custom.issue.citeThisIssue"}
				</a>
			</div>
		</div>
	</div>
	{if !$javsIssueInSidebarGrid}
		</div>
	{/if}
</section>
