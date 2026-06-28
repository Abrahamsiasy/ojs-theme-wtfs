{**
 * Single article row in the issue TOC (WTSF toc-article layout).
 *}
{assign var=publication value=$article->getCurrentPublication()}
{assign var=articlePath value=$publication->getData('urlPath')|default:$article->getId()}

{if (!$section.hideAuthor && $publication->getData('hideAuthor') == APP\submission\Submission::AUTHOR_TOC_DEFAULT) || $publication->getData('hideAuthor') == APP\submission\Submission::AUTHOR_TOC_SHOW}
	{assign var="showAuthor" value=true}
{/if}

<article class="javs_issue_toc__article">
	<div class="javs_issue_toc__article_main">
		<h3>
			<a href="{url page="article" op="view" path=$articlePath}">
				{$publication->getLocalizedTitle(null, 'html')|strip_unsafe_html}
			</a>
		</h3>
		{if $showAuthor}
			<div class="javs_issue_toc__authors">
				{capture assign=javsAuthorLine}
					{foreach from=$publication->getData('authors') item=author name=authorLoop}
						{$author->getFullName()|escape}{if !$smarty.foreach.authorLoop.last}, {/if}
					{/foreach}
				{/capture}
				{$javsAuthorLine|trim}
			</div>
		{/if}
		<div class="javs_issue_toc__actions">
			<a href="{url page="article" op="view" path=$articlePath}" class="javs_issue_toc__pill">
				{translate key="article.abstract"}
			</a>
			{foreach from=$publication->getData('galleys') item=galley}
				{if $primaryGenreIds}
					{assign var="file" value=$galley->getFile()}
					{if !$galley->getData('urlRemote') && !($file && in_array($file->getGenreId(), $primaryGenreIds))}
						{continue}
					{/if}
				{/if}
				{assign var="hasArticleAccess" value=$hasAccess}
				{if $currentContext->getSetting('publishingMode') == APP\journal\Journal::PUBLISHING_MODE_OPEN || $publication->getData('accessStatus') == APP\submission\Submission::ARTICLE_ACCESS_OPEN}
					{assign var="hasArticleAccess" value=1}
				{/if}
				{if $galley->isPdfGalley()}
					{assign var="galleyType" value="pdf"}
				{else}
					{assign var="galleyType" value="file"}
				{/if}
				{if $publication->getId() !== $article->getData('currentPublicationId')}
					{assign var="galleyPath" value=$article->getBestId()|to_array:"version":$publication->getId():$galley->getBestGalleyId()}
				{else}
					{assign var="galleyPath" value=$articlePath|to_array:$galley->getBestGalleyId()}
				{/if}
				{assign var="restricted" value=false}
				{if !$hasArticleAccess}
					{if $restrictOnlyPdf && $galleyType == "pdf"}
						{assign var="restricted" value=true}
					{elseif !$restrictOnlyPdf}
						{assign var="restricted" value=true}
					{/if}
				{/if}
				<a class="javs_issue_toc__pill javs_issue_toc__pill--galley{if $restricted} javs_issue_toc__pill--restricted{/if}"
					href="{url page="article" op="view" path=$galleyPath}">
					{$galley->getGalleyLabel()|escape}
				</a>
			{/foreach}
		</div>
	</div>
	{if $publication->getData('pages')}
		<div class="javs_issue_toc__pages">
			{translate key="plugins.themes.custom.issue.pagesPrefix" pages=$publication->getData('pages')|escape}
		</div>
	{/if}
	{call_hook name="Templates::Issue::Issue::Article"}
</article>
