{**
 * Archive issue card (JAVS archives.html style).
 *
 * @uses $issue Issue
 * @uses $javsArchive array from ArchiveLoader — also available as $javs in parent template
 *}
{assign var=stats value=$javs.issueStats[$issue->getId()]|default:[]}
{assign var=issueTitle value=""}
{if $issue->getShowTitle()}
	{assign var=issueTitle value=$issue->getLocalizedTitle()}
{/if}
{assign var=issueSeries value=$issue->getIssueSeries()}
{assign var=issueCover value=$issue->getLocalizedCoverImageUrl()}

<a href="{url op="view" path=$issue->getBestIssueId()}"
	class="javs_archive_card">
	<div class="javs_archive_card__cover{if $issueCover} javs_archive_card__cover--photo{/if}">
		{if $issueCover}
			<img
				src="{$issueCover|escape}"
				alt="{$issue->getLocalizedCoverImageAltText()|escape|default:$issueSeries|escape}"
				loading="lazy"
			>
		{else}
			<span class="javs_archive_card__cover_label">{$issueSeries|escape}</span>
		{/if}
	</div>
	<div class="javs_archive_card__body">
		<div class="javs_archive_card__vol">{$issueSeries|escape}</div>
		<h3>
			{if $issueTitle}
				{$issueTitle|escape}
			{else}
				{$issueSeries|escape}
			{/if}
		</h3>
		<div class="javs_archive_card__meta">
			{if $issue->getDatePublished()}
				<span>{$issue->getDatePublished()|date_format:"M Y"}</span>
			{/if}
			{if $stats.articleCount}
				<span>{translate key="plugins.themes.custom.archive.articleCount" numArticles=$stats.articleCount}</span>
			{/if}
		</div>
	</div>
</a>
