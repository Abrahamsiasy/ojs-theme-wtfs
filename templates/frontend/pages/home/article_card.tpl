{**
 * Article card for homepage grids.
 *
 * @uses $article Submission
 * @uses $authorUserGroups
 *}
{assign var=publication value=$article->getCurrentPublication()}
{assign var=articlePath value=$publication->getData('urlPath')|default:$article->getId()}
{assign var=sectionId value=$publication->getData('sectionId')}

<div class="javs_home_article_card">
	{if $sectionId && $javsHomepage.sections|@count}
		{foreach from=$javsHomepage.sections item=sec}
			{if $sec->getId() == $sectionId}
				<span class="javs_home_pill">{$sec->getLocalizedTitle()|escape}</span>
			{/if}
		{/foreach}
	{/if}
	<h3>
		<a href="{url page="article" op="view" path=$articlePath}">
			{$publication->getLocalizedTitle(null, 'html')|strip_unsafe_html}
		</a>
	</h3>
	<div class="javs_home_article_card__authors">
		{$publication->getAuthorString($authorUserGroups)|escape}
	</div>
	<div class="javs_home_article_card__meta">
		{if $publication->getData('datePublished')}
			<span>{$publication->getData('datePublished')|date_format:$dateFormatShort}</span>
		{/if}
		{assign var=doiObject value=$publication->getData('doiObject')}
		{if $doiObject}
			<span>{$doiObject->getData('doi')|escape}</span>
		{/if}
	</div>
</div>
