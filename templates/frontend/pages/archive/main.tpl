{**
 * Archive main column — year filter, issue card grid, pagination.
 *}

{if $javs.years && $javs.years|@count}
	<form class="javs_archive_year_filter" method="get" action="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive"}">
		<label for="javsArchiveYear">{translate key="plugins.themes.custom.archive.filterByYear"}</label>
		<select name="year" id="javsArchiveYear" onchange="this.form.submit()">
			<option value="">{translate key="plugins.themes.custom.archive.allYears"}</option>
			{foreach from=$javs.years item=year}
				<option value="{$year|escape}"{if $javs.selectedYear == $year} selected="selected"{/if}>
					{$year|escape}
				</option>
			{/foreach}
		</select>
		<noscript>
			<button type="submit" class="javs_btn javs_btn--outline">{translate key="common.view"}</button>
		</noscript>
	</form>
{/if}

{if empty($issues)}
	<p class="javs_archive_empty">{translate key="plugins.themes.custom.archive.noIssuesForYear"}</p>
{else}
	<div class="javs_archive_issues" id="javsArchiveIssues">
		{foreach from=$issues item=issue}
			{include file="frontend/objects/issue_archive_card.tpl" issue=$issue}
		{/foreach}
	</div>
{/if}

{if $prevPage > 1}
	{if $javs.selectedYear}
		{capture assign=prevUrl}{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive" path=$prevPage year=$javs.selectedYear}{/capture}
	{else}
		{capture assign=prevUrl}{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive" path=$prevPage}{/capture}
	{/if}
{elseif $prevPage === 1}
	{if $javs.selectedYear}
		{capture assign=prevUrl}{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive" year=$javs.selectedYear}{/capture}
	{else}
		{capture assign=prevUrl}{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive"}{/capture}
	{/if}
{/if}
{if $nextPage}
	{if $javs.selectedYear}
		{capture assign=nextUrl}{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive" path=$nextPage year=$javs.selectedYear}{/capture}
	{else}
		{capture assign=nextUrl}{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive" path=$nextPage}{/capture}
	{/if}
{/if}

{if $prevUrl || $nextUrl}
	<nav class="javs_archive_pagination" aria-label="{translate|escape key="common.pagination.label"}">
		{if $prevUrl}
			<a href="{$prevUrl|escape}" class="javs_archive_pagination__link">‹</a>
		{/if}
		<span class="javs_archive_pagination__current">
			{translate key="common.pagination" start=$showingStart end=$showingEnd total=$total}
		</span>
		{if $nextUrl}
			<a href="{$nextUrl|escape}" class="javs_archive_pagination__link">›</a>
		{/if}
	</nav>
{/if}
