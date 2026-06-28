{**
 * Issue cover card — shared by hero and sidebar mini.
 *
 * @uses $variant string hero|mini
 * @uses $linked bool Whether the cover is wrapped in a link
 *}
{assign var=issueCover value=$issue->getLocalizedCoverImageUrl()}
{assign var=issueTitle value=$issue->getLocalizedTitle()|default:$currentJournal->getLocalizedName()}
{assign var=javsCoverAcronym value=$currentJournal->getLocalizedData('acronym')|default:$currentJournal->getLocalizedName()}
{assign var=javsCoverMid value=$issueTitle}
{assign var=javsCoverSub value=""}
{if $currentLocale == 'zh_Hans'}
	{assign var=javsCoverSub value=$currentJournal->getLocalizedName('en')}
{elseif $currentJournal->getLocalizedName('zh_Hans')}
	{assign var=javsCoverSub value=$currentJournal->getLocalizedName('zh_Hans')}
{/if}
{if $javsCoverSub == $javsCoverMid}{assign var=javsCoverSub value=""}{/if}
{capture assign=javsCoverAlt}
	{translate key="issue.viewIssueIdentification" identification=$issue->getIssueIdentification()|escape}
{/capture}

{assign var=coverClass value="javs_issue_cover javs_issue_cover--{$variant}"}
{if $issueCover}
	{assign var=coverClass value="{$coverClass} javs_issue_cover--photo"}
{else}
	{assign var=coverClass value="{$coverClass} javs_issue_cover--placeholder"}
{/if}

{if $linked|default:false}
	<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="view" path=$issue->getBestIssueId()}" class="{$coverClass|escape}">
{else}
	<div class="{$coverClass|escape}">
{/if}
	{if $issueCover}
		<img
			class="javs_issue_cover__img"
			src="{$issueCover|escape}"
			alt="{$issue->getLocalizedCoverImageAltText()|escape|default:$javsCoverAlt}"
			loading="lazy"
		>
	{/if}
	<span class="javs_issue_cover__overlay">
		<span class="javs_issue_cover__top">{$javsCoverAcronym|escape}</span>
		<span class="javs_issue_cover__center">
			<span class="javs_issue_cover__mid">{$javsCoverMid|escape}</span>
			{if $javsCoverSub}
				<span class="javs_issue_cover__mid-zh">{$javsCoverSub|escape}</span>
			{/if}
		</span>
		<span class="javs_issue_cover__bot">{$issue->getIssueIdentification()|escape}</span>
	</span>
{if $linked|default:false}
	</a>
{else}
	</div>
{/if}
