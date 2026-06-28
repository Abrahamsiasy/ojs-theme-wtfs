{**
 * Issue TOC article groups (main column).
 *}
{foreach name=sections from=$publishedSubmissions item=section}
	{if $section.articles|@count}
		<div class="javs_issue_toc__group">
			{if $section.title}
				<h2>{$section.title|escape}</h2>
			{/if}
			{foreach from=$section.articles item=article}
				{include file="frontend/objects/issue_toc_article.tpl" article=$article section=$section}
			{/foreach}
		</div>
	{/if}
{/foreach}
