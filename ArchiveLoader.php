<?php

/**
 * @file plugins/themes/custom/ArchiveLoader.php
 *
 * Loads dynamic data for the custom theme issue archive page.
 */

namespace APP\plugins\themes\custom;

use APP\core\Application;
use APP\facades\Repo;
use APP\issue\Collector as IssueCollector;
use APP\issue\Issue;
use PKP\config\Config;
use PKP\plugins\Hook;
use PKP\submission\PKPSubmission;

class ArchiveLoader
{
    public static function register(CustomThemePlugin $theme): void
    {
        Hook::add('TemplateManager::display', [self::class, 'loadArchiveData']);
    }

    /**
     * @param array $args [TemplateManager, string &$template, mixed &$output]
     */
    public static function loadArchiveData(string $hookName, array $args): bool
    {
        $templateMgr = $args[0];
        $template = $args[1];

        if ($template !== 'frontend/pages/issueArchive.tpl') {
            return Hook::CONTINUE;
        }

        $request = Application::get()->getRequest();
        $journal = $request->getJournal();
        if (!$journal) {
            return Hook::CONTINUE;
        }

        $years = Repo::issue()->getYearsIssuesPublished($journal->getId())
            ->sort()
            ->reverse()
            ->values()
            ->all();

        $selectedYear = self::resolveSelectedYear($request->getUserVar('year'), $years);
        $issues = $templateMgr->getTemplateVars('issues') ?? [];

        if ($selectedYear !== null) {
            $page = self::getCurrentPage($request);
            $count = $journal->getData('itemsPerPage')
                ?: Config::getVar('interface', 'items_per_page');
            $offset = $page > 1 ? ($page - 1) * $count : 0;

            $collector = Repo::issue()->getCollector()
                ->limit($count)
                ->offset($offset)
                ->filterByContextIds([$journal->getId()])
                ->orderBy(IssueCollector::ORDERBY_SEQUENCE)
                ->filterByPublished(true)
                ->filterByYears([$selectedYear]);

            $issues = $collector->getMany()->toArray();
            $total = $collector->getCount();
            $showingStart = $total > 0 ? $offset + 1 : 0;
            $showingEnd = min($offset + $count, $offset + count($issues));
            $nextPage = $total > $showingEnd ? $page + 1 : null;
            $prevPage = $showingStart > 1 ? $page - 1 : null;

            $templateMgr->assign([
                'issues' => $issues,
                'showingStart' => $showingStart,
                'showingEnd' => $showingEnd,
                'total' => $total,
                'nextPage' => $nextPage,
                'prevPage' => $prevPage,
            ]);
        }

        $issueStats = [];
        foreach ($issues as $issue) {
            $issueStats[$issue->getId()] = [
                'articleCount' => self::countPublishedArticles($issue),
                'year' => self::getIssueYear($issue),
            ];
        }

        $templateMgr->assign([
            'isFullWidth' => true,
            'javsArchive' => [
                'issueStats' => $issueStats,
                'years' => $years,
                'selectedYear' => $selectedYear,
            ],
        ]);

        return Hook::CONTINUE;
    }

    /**
     * @param array<int, int> $years
     */
    private static function resolveSelectedYear(mixed $yearParam, array $years): ?int
    {
        if ($yearParam === null || $yearParam === '') {
            return null;
        }

        $year = (int) $yearParam;
        if (!$year || !in_array($year, $years, true)) {
            return null;
        }

        return $year;
    }

    private static function getCurrentPage(\PKP\core\PKPRequest $request): int
    {
        $args = $request->getRequestedArgs();
        if (!empty($args[0]) && ctype_digit((string) $args[0])) {
            return max(1, (int) $args[0]);
        }

        return 1;
    }

    private static function countPublishedArticles(Issue $issue): int
    {
        return Repo::submission()->getCollector()
            ->filterByContextIds([$issue->getJournalId()])
            ->filterByIssueIds([$issue->getId()])
            ->filterByStatus([PKPSubmission::STATUS_PUBLISHED])
            ->getCount();
    }

    private static function getIssueYear(Issue $issue): ?int
    {
        if ($issue->getYear()) {
            return (int) $issue->getYear();
        }

        if ($issue->getDatePublished()) {
            return (int) date('Y', strtotime($issue->getDatePublished()));
        }

        return null;
    }
}
