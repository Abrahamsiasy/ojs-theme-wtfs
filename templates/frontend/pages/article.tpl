{**
 * plugins/themes/custom/templates/frontend/pages/article.tpl
 *
 * WTSF-style article view — cream header band, two-column body, dynamic sidebar blocks.
 *}
{include file="frontend/components/header.tpl" pageTitleTranslated=$article->getCurrentPublication()->getLocalizedFullTitle(null, 'html')|strip_unsafe_html}

{assign var=javs value=$javsArticle|default:[]}
{capture assign=javsArticleSidebar}{call_hook name="Templates::Common::Sidebar"}{/capture}

<div class="page page_article javs_article_page">

	<nav class="javs_breadcrumb" aria-label="{translate key="navigation.breadcrumbLabel"}">
		<div class="javs_article_container">
			<a href="{url page="index" router=PKP\core\PKPApplication::ROUTE_PAGE}">{translate key="common.homepageNavigationLabel"}</a>
			<span class="javs_breadcrumb__sep" aria-hidden="true">→</span>
			<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive"}">{translate key="navigation.archives"}</a>
			{if $issue}
				<span class="javs_breadcrumb__sep" aria-hidden="true">→</span>
				<a href="{url page="issue" op="view" path=$issue->getBestIssueId()}">{$issue->getIssueIdentification()|escape}</a>
			{/if}
			<span class="javs_breadcrumb__sep" aria-hidden="true">→</span>
			<span class="javs_breadcrumb__current" aria-current="page">{$publication->getLocalizedTitle(null, 'html')|strip_unsafe_html|truncate:80:"…"}</span>
		</div>
	</nav>

	{include file="frontend/objects/article_details.tpl" javsArticleSidebar=$javsArticleSidebar}

</div>

{include file="frontend/components/footer.tpl"}
