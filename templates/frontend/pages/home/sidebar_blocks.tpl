{**
 * OJS sidebar / custom blocks — right column beside cream homepage sections.
 *
 * @uses $javsHomeSidebar string HTML from Templates::Common::Sidebar hook
 *}
{if $javsHomeSidebar}
	<aside class="javs_home_with_sidebar__sidebar" aria-label="{translate key="common.navigation.sidebar"}">
		<div class="javs_home_sidebar__stack">
			{$javsHomeSidebar}
		</div>
	</aside>
{/if}
