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
				<span class="javs_home_pill javs_home_article_card__type">{$sec->getLocalizedTitle()|escape}</span>
			{/if}
		{/foreach}
	{/if}
	<h3 class="javs_home_article_card__title">
		<a href="{url page="article" op="view" path=$articlePath}">
			{$publication->getLocalizedTitle(null, 'html')|strip_unsafe_html}
		</a>
	</h3>
	<div class="javs_home_article_card__authors">
		{$publication->getAuthorString($authorUserGroups)|escape}
	</div>
	<div class="javs_home_article_card__meta">
		{if $publication->getData('datePublished')}
			<div class="javs_home_article_card__date">
				<span class="javs_home_article_card__meta-label">{translate key="submissions.published"}:</span>
				<time datetime="{$publication->getData('datePublished')|date_format:'%Y-%m-%d'}">{$publication->getData('datePublished')|date_format:$dateFormatShort}</time>
			</div>
		{/if}
		{assign var=doiObject value=$publication->getData('doiObject')}
		{if $doiObject}
			{assign var=doiUrl value=$doiObject->getData('resolvingUrl')|escape}
			<div class="javs_home_article_card__doi">
				<span class="javs_home_article_card__doi-label">{translate key="doi.readerDisplayName"}:</span>
				<a href="{$doiUrl}" class="javs_home_article_card__doi-link">{$doiObject->getDoi()|escape}</a>
			</div>
		{/if}
	</div>
</div>
