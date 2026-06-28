<?php

/**
 * @file plugins/themes/custom/HomepageLoader.php
 *
 * Loads dynamic homepage data for the custom theme journal index.
 */

namespace APP\plugins\themes\custom;

use APP\core\Application;
use APP\facades\Repo;
use APP\journal\Journal;
use APP\submission\Collector as SubmissionCollector;
use PKP\context\Context;
use PKP\plugins\Hook;
use PKP\security\Role;
use PKP\submission\PKPSubmission;
use PKP\template\PKPTemplateManager;
use PKP\userGroup\UserGroup;
use PKP\userGroup\UserUserGroup;

class HomepageLoader
{
    private static ?CustomThemePlugin $theme = null;

    private const HERO_TITLE_MAX = 100;
    private const HERO_SUBTITLE_MAX = 200;
    private const HERO_SECONDARY_MAX = 64;

    public static function register(CustomThemePlugin $theme): void
    {
        self::$theme = $theme;
        Hook::add('TemplateManager::display', [self::class, 'loadHomepageData']);
    }

    /**
     * @param array $args [TemplateManager, string &$template, mixed &$output]
     */
    public static function loadHomepageData(string $hookName, array $args): bool
    {
        $templateMgr = $args[0];
        $template = $args[1];

        if ($template !== 'frontend/pages/indexJournal.tpl') {
            return Hook::CONTINUE;
        }

        $request = Application::get()->getRequest();
        $journal = $request->getJournal();
        if (!$journal instanceof Journal || !self::$theme) {
            return Hook::CONTINUE;
        }

        $templateMgr->assign([
            'isFullWidth' => true,
            'javsHomepage' => self::buildHomepageData($journal, self::$theme),
        ]);

        return Hook::CONTINUE;
    }

    /**
     * @return array<string, mixed>
     */
    public static function buildHomepageData(Journal $journal, CustomThemePlugin $theme): array
    {
        $contextId = $journal->getId();
        $locale = \PKP\facades\Locale::getLocale();

        $publishedCount = Repo::submission()->getCollector()
            ->filterByContextIds([$contextId])
            ->filterByStatus([PKPSubmission::STATUS_PUBLISHED])
            ->getCount();

        $issueCount = Repo::issue()->getCollector()
            ->filterByContextIds([$contextId])
            ->filterByPublished(true)
            ->getCount();

        $recentLimit = self::getRecentArticlesBatchSize($theme);
        $recentArticles = self::fetchRecentArticles($contextId, 0, $recentLimit);
        $recentArticlesLoaded = count($recentArticles);

        $showSubjectAreas = (bool) $theme->getOption('homepageShowSubjectAreas');
        $sections = Repo::section()->getCollector()
            ->filterByContextIds([$contextId])
            ->excludeInactive(true)
            ->getMany()
            ->all();

        $indexedRaw = $theme->getOption('homepageIndexedDatabases') ?: '';
        $request = Application::get()->getRequest();
        $indexedAssetBase = $request->getBaseUrl() . '/' . $theme->getPluginPath();
        $indexedDatabases = IndexedDatabaseHelper::parse($indexedRaw, $indexedAssetBase);

        $authorUserGroups = UserGroup::withRoleIds([Role::ROLE_ID_AUTHOR])
            ->withContextIds([$contextId])
            ->get();

        return [
            'heroTagline' => self::getHeroTagline($journal, $locale),
            'heroSubtitle' => self::getHeroSubtitle($journal),
            'heroSecondaryTitle' => self::trimText($journal->getLocalizedName($locale), self::HERO_SECONDARY_MAX),
            'eyebrow' => self::buildEyebrow($journal),
            'featuredArticle' => self::getFeaturedArticle($journal),
            'publishedCount' => $publishedCount,
            'issueCount' => $issueCount,
            'firstPublishedYear' => self::getFirstPublishedYear($contextId),
            'statsReviewTime' => $theme->getOption('homepageStatsReviewTime') ?: __('plugins.themes.custom.homepage.statsReviewTimeDefault'),
            'indexedCount' => count($indexedDatabases) ?: 10,
            'indexedDatabases' => $indexedDatabases,
            'recentArticles' => $recentArticles,
            'recentArticlesHasMore' => $recentArticlesLoaded < $publishedCount,
            'recentArticlesNextOffset' => $recentArticlesLoaded,
            'authorUserGroups' => $authorUserGroups,
            'showSubjectAreas' => $showSubjectAreas,
            'sections' => $sections,
            'mastheadPreview' => self::getMastheadPreview($journal, max(1, min(10, (int) ($theme->getOption('homepageMastheadLimit') ?: 5)))),
            'doiPrefix' => $journal->getData('doiPrefix'),
            'supportedLocaleCount' => count($journal->getSupportedLocaleNames()),
        ];
    }

    public static function getRecentArticlesBatchSize(CustomThemePlugin $theme): int
    {
        return max(1, min(12, (int) ($theme->getOption('homepageRecentArticlesCount') ?: 12)));
    }

    public static function getPublishedArticleCount(int $contextId): int
    {
        return Repo::submission()->getCollector()
            ->filterByContextIds([$contextId])
            ->filterByStatus([PKPSubmission::STATUS_PUBLISHED])
            ->getCount();
    }

    /**
     * @return array<int, \APP\submission\Submission>
     */
    public static function fetchRecentArticles(int $contextId, int $offset, int $limit): array
    {
        return Repo::submission()->getCollector()
            ->filterByContextIds([$contextId])
            ->filterByStatus([PKPSubmission::STATUS_PUBLISHED])
            ->orderBy(SubmissionCollector::ORDERBY_DATE_PUBLISHED, SubmissionCollector::ORDER_DIR_DESC)
            ->limit($limit)
            ->offset($offset)
            ->getMany()
            ->all();
    }

    /**
     * @return array{html: string, count: int}
     */
    public static function renderRecentArticleCards(Journal $journal, CustomThemePlugin $theme, int $offset, int $limit): array
    {
        $articles = self::fetchRecentArticles($journal->getId(), $offset, $limit);
        if (!$articles) {
            return ['html' => '', 'count' => 0];
        }

        $request = Application::get()->getRequest();
        $templateMgr = PKPTemplateManager::getManager($request);
        $authorUserGroups = UserGroup::withRoleIds([Role::ROLE_ID_AUTHOR])
            ->withContextIds([$journal->getId()])
            ->get();
        $sections = Repo::section()->getCollector()
            ->filterByContextIds([$journal->getId()])
            ->excludeInactive(true)
            ->getMany()
            ->all();

        $templateMgr->assign([
            'javsHomepage' => [
                'sections' => $sections,
            ],
            'authorUserGroups' => $authorUserGroups,
        ]);

        $html = '';
        foreach ($articles as $article) {
            $templateMgr->assign('article', $article);
            $html .= $templateMgr->fetch('frontend/pages/home/article_card.tpl');
        }

        return ['html' => $html, 'count' => count($articles)];
    }

    private static function getHeroTagline(Journal $journal, string $locale): string
    {
        $description = strip_tags((string) $journal->getLocalizedData('description'));
        if ($description !== '') {
            $sentences = preg_split('/(?<=[.!?])\s+/', $description, 2);
            $first = trim($sentences[0] ?? '');
            if ($first !== '') {
                return self::trimText($first, self::HERO_TITLE_MAX);
            }
        }

        return self::trimText($journal->getLocalizedName($locale), self::HERO_TITLE_MAX);
    }

    private static function getHeroSubtitle(Journal $journal): string
    {
        $description = strip_tags((string) $journal->getLocalizedData('description'));
        if ($description === '') {
            return '';
        }

        return self::trimText($description, self::HERO_SUBTITLE_MAX);
    }

    private static function trimText(string $text, int $maxLen): string
    {
        $text = preg_replace('/\s+/u', ' ', trim($text));
        if ($text === '' || mb_strlen($text) <= $maxLen) {
            return $text;
        }

        $truncated = mb_substr($text, 0, $maxLen);
        $lastSpace = mb_strrpos($truncated, ' ');
        if ($lastSpace !== false && $lastSpace > (int) ($maxLen * 0.55)) {
            $truncated = mb_substr($truncated, 0, $lastSpace);
        }

        return rtrim($truncated, '.,;:!?') . '…';
    }

    private static function buildEyebrow(Journal $journal): string
    {
        $parts = [];
        if (count($journal->getSupportedLocaleNames()) > 1) {
            $parts[] = __('plugins.themes.custom.homepage.eyebrow.bilingual');
        }
        if ($journal->getData('publishingMode') == Journal::PUBLISHING_MODE_OPEN || $journal->getData('openAccessPolicy')) {
            $parts[] = __('reader.openAccess');
        }
        $parts[] = __('plugins.themes.custom.topbar.peerReviewed');

        return implode(' · ', $parts);
    }

    /**
     * @return array<string, mixed>|null
     */
    private static function getFeaturedArticle(Journal $journal): ?array
    {
        $issue = Repo::issue()->getCurrent($journal->getId(), true);
        if (!$issue) {
            return null;
        }

        $submission = Repo::submission()->getCollector()
            ->filterByContextIds([$journal->getId()])
            ->filterByIssueIds([$issue->getId()])
            ->filterByStatus([PKPSubmission::STATUS_PUBLISHED])
            ->orderBy(SubmissionCollector::ORDERBY_SEQUENCE, SubmissionCollector::ORDER_DIR_ASC)
            ->limit(1)
            ->getMany()
            ->first();

        if (!$submission) {
            return null;
        }

        $publication = $submission->getCurrentPublication();

        return [
            'submission' => $submission,
            'publication' => $publication,
            'issueIdentification' => $issue->getIssueIdentification(),
        ];
    }

    private static function getFirstPublishedYear(int $contextId): ?int
    {
        $year = Repo::issue()->getYearsIssuesPublished($contextId)->sort()->first();

        return $year !== null ? (int) $year : null;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private static function getMastheadPreview(Context $context, int $limit): array
    {
        $mastheadRoles = UserGroup::withContextIds([$context->getId()])
            ->masthead(true)
            ->excludeRoles([Role::ROLE_ID_REVIEWER])
            ->get();

        $savedOrder = (array) $context->getData('mastheadUserGroupIds');
        $mastheadRoles = $mastheadRoles->sortBy(function ($userGroup) use ($savedOrder) {
            $index = array_search($userGroup->id, $savedOrder);
            return $index === false ? PHP_INT_MAX : $index;
        });

        $allUsersIdsGroupedByUserGroupId = Repo::userGroup()->getMastheadUserIdsByRoleIds(
            $mastheadRoles->all(),
            $context->getId()
        );

        $preview = [];
        foreach ($mastheadRoles as $userGroupId => $mastheadUserGroup) {
            if (count($preview) >= $limit) {
                break;
            }
            foreach ($allUsersIdsGroupedByUserGroupId[$userGroupId] ?? [] as $userId) {
                if (count($preview) >= $limit) {
                    break 2;
                }
                $user = Repo::user()->get($userId);
                if (!$user) {
                    continue;
                }
                $userUserGroup = UserUserGroup::withUserId($user->getId())
                    ->withUserGroupIds([$userGroupId])
                    ->withActive()
                    ->withMasthead()
                    ->first();
                if (!$userUserGroup) {
                    continue;
                }
                $preview[] = [
                    'user' => $user,
                    'role' => $mastheadUserGroup->getLocalizedData('name'),
                    'initials' => self::getInitials($user->getFullName()),
                ];
            }
        }

        return $preview;
    }

    private static function getInitials(string $name): string
    {
        $parts = preg_split('/\s+/', trim($name));
        $initials = '';
        foreach ($parts as $part) {
            if ($part !== '') {
                $initials .= mb_strtoupper(mb_substr($part, 0, 1));
            }
        }

        return mb_substr($initials, 0, 2);
    }
}
