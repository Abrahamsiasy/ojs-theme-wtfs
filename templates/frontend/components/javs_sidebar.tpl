{**
 * Shared sidebar column for OJS custom blocks (issue view, archive, etc.).
 *
 * @uses $sidebarHtml string HTML from Templates::Common::Sidebar hook
 *}
{if $sidebarHtml}
	<aside class="javs_issue_sidebar" aria-label="{translate key="common.navigation.sidebar"}">
		<div class="javs_issue_sidebar__blocks">
			{$sidebarHtml}
		</div>
	</aside>
{/if}
