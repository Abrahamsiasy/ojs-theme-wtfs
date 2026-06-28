{**
 * plugins/themes/custom/templates/frontend/pages/issue.tpl
 *
 * WTSF-style issue view — dynamic OJS data, cream canvas, embedded sidebar.
 *}
{include file="frontend/components/header.tpl" pageTitleTranslated=$issueIdentification|default:""}

{assign var=javs value=$javsIssue|default:[]}
{capture assign=javsIssueSidebar}{call_hook name="Templates::Common::Sidebar"}{/capture}

<div class="page page_issue javs_issue">

	{if !$issue}
		<section class="javs_issue_section javs_issue_section--cream">
			<div class="javs_issue_container">
				<h1>{translate key="current.noCurrentIssue"}</h1>
				{include file="frontend/components/notification.tpl" type="warning" messageKey="current.noCurrentIssueDesc"}
			</div>
		</section>

	{else}
		{if !$issue->getPublished()}
			<div class="javs_issue_container">
				{include file="frontend/components/notification.tpl" type="warning" messageKey="editor.issues.preview"}
			</div>
		{/if}

		{* Hero + TOC share one main column when sidebar blocks are present *}
		{if $javsIssueSidebar}
			{assign var=javsIssueInSidebarGrid value=true}
			<div class="javs_issue_with_sidebar">
				<div class="javs_issue_with_sidebar__main">
					{include file="frontend/pages/issue/hero.tpl"}
					<section class="javs_issue_toc javs_issue_section">
						{include file="frontend/objects/issue_toc_main.tpl"}
					</section>
				</div>
				{include file="frontend/components/javs_sidebar.tpl" sidebarHtml=$javsIssueSidebar}
			</div>
		{else}
			{assign var=javsIssueInSidebarGrid value=false}
			{include file="frontend/pages/issue/hero.tpl"}
			<section class="javs_issue_toc javs_issue_section">
				<div class="javs_issue_container">
					{include file="frontend/objects/issue_toc_main.tpl"}
				</div>
			</section>
		{/if}
	{/if}

</div>

{include file="frontend/components/footer.tpl"}
