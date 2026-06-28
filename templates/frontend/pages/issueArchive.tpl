{**
 * plugins/themes/custom/templates/frontend/pages/issueArchive.tpl
 *
 * JAVS-style issue archive — hero, card grid, sidebar blocks.
 *}
{capture assign="pageTitle"}
	{if $prevPage}
		{translate key="archive.archivesPageNumber" pageNumber=$prevPage+1}
	{else}
		{translate key="archive.archives"}
	{/if}
{/capture}
{include file="frontend/components/header.tpl" pageTitleTranslated=$pageTitle}

{assign var=javs value=$javsArchive|default:[]}
{capture assign=javsSidebarHtml}{call_hook name="Templates::Common::Sidebar"}{/capture}

<div class="page page_issue_archive javs_archive">

	<section class="javs_archive_hero">
		<div class="javs_archive_container">
			<h1>{translate key="archive.archives"}</h1>
			<p>{translate key="plugins.themes.custom.archive.lead" journalName=$currentJournal->getLocalizedName()|escape}</p>
		</div>
	</section>

	<section class="javs_archive_section">
		{if empty($issues) && !$javs.selectedYear}
			<div class="javs_archive_container">
				<p class="javs_archive_empty">{translate key="current.noCurrentIssueDesc"}</p>
			</div>
		{elseif $javsSidebarHtml}
			<div class="javs_issue_with_sidebar">
				<div class="javs_issue_with_sidebar__main">
					{include file="frontend/pages/archive/main.tpl"}
				</div>
				{include file="frontend/components/javs_sidebar.tpl" sidebarHtml=$javsSidebarHtml}
			</div>
		{else}
			<div class="javs_archive_container">
				{include file="frontend/pages/archive/main.tpl"}
			</div>
		{/if}
	</section>

</div>

{include file="frontend/components/footer.tpl"}
