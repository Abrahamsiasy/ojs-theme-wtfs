{**
 * plugins/themes/custom/templates/frontend/components/header.tpl
 *
 * WTSF/JTS-style header: topbar strip + sticky navbar (reference: ojs-theme-wtsf-2-main).
 *}
{strip}
	{assign var="showingLogo" value=true}
	{if !$displayPageHeaderLogo}
		{assign var="showingLogo" value=false}
	{/if}
{/strip}
<!DOCTYPE html>
<html lang="{$currentLocale|replace:"_":"-"}" xml:lang="{$currentLocale|replace:"_":"-"}">
{if !$pageTitleTranslated}{capture assign="pageTitleTranslated"}{translate key=$pageTitle}{/capture}{/if}
{include file="frontend/components/headerHead.tpl"}
<body class="pkp_page_{$requestedPage|escape|default:"index"} pkp_op_{$requestedOp|escape|default:"index"}{if $showingLogo} has_site_logo{/if}" dir="{$currentLocaleLangDir|escape|default:"ltr"}">

	<div class="pkp_structure_page">

		<header class="pkp_structure_head javs_header" id="headerNavigationContainer" role="banner">
			{include file="frontend/components/skipLinks.tpl"}

			{if $currentContext}
				{assign var="javs_eissn" value=$currentContext->getData('onlineIssn')}
				{assign var="javs_pissn" value=$currentContext->getData('printIssn')}
				{assign var="javs_oa" value=$currentContext->getData('openAccessPolicy')}

				<div class="javs_topbar">
					<div class="javs_header_container javs_topbar_row">
						<div class="javs_topbar_meta" aria-label="{translate key='plugins.themes.custom.topbar.metaLabel'}">
							{if $javs_eissn}
								<span class="javs_issn" title="{translate key='manager.setup.onlineIssn'}">
									{translate key="plugins.themes.custom.topbar.issnOnline"}&nbsp;{$javs_eissn|escape}
								</span>
							{/if}
							{if $javs_pissn}
								<span class="javs_issn" title="{translate key='manager.setup.printIssn'}">
									{translate key="plugins.themes.custom.topbar.issnPrint"}&nbsp;{$javs_pissn|escape}
								</span>
							{/if}
							{if $javs_oa}
								<span class="javs_badge javs_badge--oa" title="{translate key='about.openAccessPolicy'}">
									{translate key="reader.openAccess"}
								</span>
							{/if}
							<span class="javs_badge javs_badge--pr" title="{translate key='about.peerReviewProcess'}">
								{translate key="plugins.themes.custom.topbar.peerReviewed"}
							</span>
						</div>
						<div class="javs_topbar_links">
							{if !$currentContext->getData('disableSubmissions')}
								<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="about" op="submissions"}">
									{translate key="plugins.themes.custom.topbar.makeSubmission"}
								</a>
							{/if}
							{load_menu name="user" id="navigationUser" ulClass="pkp_navigation_user" liClass="profile"}
						</div>
					</div>
				</div>
			{/if}

			<div class="javs_navbar">
				<div class="javs_header_container pkp_head_wrapper">

					<div class="pkp_site_name_wrapper">
						<button type="button" class="pkp_site_nav_toggle" aria-expanded="false" aria-controls="siteNavMenu">
							<span class="pkp_screen_reader">{translate key="plugins.themes.custom.nav.openMenu"}</span>
							{literal}
							<svg class="javs_menu_icon" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
								<line x1="3" y1="6" x2="21" y2="6"/>
								<line x1="3" y1="12" x2="21" y2="12"/>
								<line x1="3" y1="18" x2="21" y2="18"/>
							</svg>
							{/literal}
						</button>
						{if !$requestedPage || $requestedPage === 'index'}
							<h1 class="pkp_screen_reader">
								{if $currentContext}
									{$displayPageHeaderTitle|escape}
								{else}
									{$siteTitle|escape}
								{/if}
							</h1>
						{/if}
						<div class="pkp_site_name">
						{capture assign="homeUrl"}
							{url page="index" router=PKP\core\PKPApplication::ROUTE_PAGE}
						{/capture}
						{if $currentContext}
							{assign var="javs_logo_main" value=$currentContext->getLocalizedData('acronym')}
							{assign var="javs_logo_sub" value=$currentContext->getLocalizedName()}
							{if !$javs_logo_main}
								{assign var="javs_logo_main" value=$javs_logo_sub}
								{assign var="javs_logo_sub" value=""}
							{/if}
						{/if}
						{if $displayPageHeaderLogo}
							<a href="{$homeUrl}" class="javs_logo is_img javs_logo--solo">
								<img src="{$publicFilesDir}/{$displayPageHeaderLogo.uploadName|escape:"url"}" {if $displayPageHeaderLogo.altText != ''}alt="{$displayPageHeaderLogo.altText|escape}"{else}alt="{$javs_logo_main|default:$displayPageHeaderTitle|escape}"{/if} />
							</a>
						{elseif $displayPageHeaderTitle}
							<a href="{$homeUrl}" class="javs_logo is_text">
								<span class="javs_logo_text">
									<span class="javs_logo__main">{$javs_logo_main|default:$displayPageHeaderTitle|escape}</span>
									{if $javs_logo_sub && $javs_logo_sub != $javs_logo_main}<span class="javs_logo__sub">{$javs_logo_sub|escape}</span>{/if}
								</span>
							</a>
						{else}
							<a href="{$homeUrl}" class="javs_logo is_img">
								<img src="{$baseUrl}/templates/images/structure/logo.png" alt="{$applicationName|escape}" title="{$applicationName|escape}" width="180" height="90" />
							</a>
						{/if}
						</div>
					</div>

					{capture assign="primaryMenu"}
						{load_menu name="primary" id="navigationPrimary" ulClass="pkp_navigation_primary javs_nav_links"}
					{/capture}

					<nav class="pkp_site_nav_menu" id="siteNavMenu" aria-label="{translate|escape key="common.navigation.site"}">
						<a id="siteNav"></a>
						<div class="pkp_navigation_primary_row">
							<div class="pkp_navigation_primary_wrapper">
								{$primaryMenu}
								{if $currentContext && $requestedPage !== 'search'}
									<div class="pkp_navigation_search_wrapper">
										<a href="{url page="search"}" class="pkp_search pkp_search_desktop">
											<span class="fa fa-search" aria-hidden="true"></span>
											{translate key="common.search"}
										</a>
									</div>
								{/if}
							</div>
						</div>
					</nav>

				</div>
			</div>
		</header>

		{if $isFullWidth}
			{assign var=hasSidebar value=0}
		{/if}
		<div class="pkp_structure_content{if $hasSidebar} has_sidebar{/if}">
			<div class="pkp_structure_main" role="main">
				<a id="pkp_content_main"></a>
