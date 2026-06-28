<?php

/**
 * @file plugins/themes/custom/IssueLoader.php
 *
 * Loads dynamic data for the custom theme issue view page.
 */

namespace APP\plugins\themes\custom;

use APP\core\Application;
use APP\issue\Issue;
use PKP\plugins\Hook;
use PKP\template\PKPTemplateManager;

class IssueLoader
{
    public static function register(CustomThemePlugin $theme): void
    {
        Hook::add('TemplateManager::display', [self::class, 'loadIssueData']);
    }

    /**
     * @param array $args [TemplateManager, string &$template, mixed &$output]
     */
    public static function loadIssueData(string $hookName, array $args): bool
    {
        $templateMgr = $args[0];
        $template = $args[1];

        if ($template !== 'frontend/pages/issue.tpl') {
            return Hook::CONTINUE;
        }

        /** @var Issue|null $issue */
        $issue = $templateMgr->getTemplateVars('issue');
        if (!$issue) {
            $templateMgr->assign('isFullWidth', true);
            return Hook::CONTINUE;
        }

        $request = Application::get()->getRequest();
        if (!$request->getJournal()) {
            return Hook::CONTINUE;
        }

        $publishedSubmissions = $templateMgr->getTemplateVars('publishedSubmissions') ?? [];

        $templateMgr->assign([
            'isFullWidth' => true,
            'javsIssue' => [
                'articleCount' => self::countArticles($publishedSubmissions),
                'pageRange' => self::getPageRange($publishedSubmissions),
            ],
        ]);

        return Hook::CONTINUE;
    }

    /**
     * @param array<int, array{title: ?string, hideAuthor: bool, articles: array}> $publishedSubmissions
     */
    private static function countArticles(array $publishedSubmissions): int
    {
        $count = 0;
        foreach ($publishedSubmissions as $section) {
            $count += count($section['articles'] ?? []);
        }

        return $count;
    }

    /**
     * @param array<int, array{title: ?string, hideAuthor: bool, articles: array}> $publishedSubmissions
     */
    private static function getPageRange(array $publishedSubmissions): ?string
    {
        $starts = [];
        $ends = [];

        foreach ($publishedSubmissions as $section) {
            foreach ($section['articles'] ?? [] as $article) {
                $pages = $article->getCurrentPublication()->getData('pages');
                if (!$pages) {
                    continue;
                }
                if (preg_match('/^(\d+)/', (string) $pages, $startMatch)) {
                    $starts[] = (int) $startMatch[1];
                }
                if (preg_match('/-(\d+)/', (string) $pages, $endMatch)) {
                    $ends[] = (int) $endMatch[1];
                } elseif (preg_match('/^(\d+)$/', (string) $pages, $singleMatch)) {
                    $ends[] = (int) $singleMatch[1];
                }
            }
        }

        if (empty($starts) || empty($ends)) {
            return null;
        }

        return min($starts) . '–' . max($ends);
    }
}
