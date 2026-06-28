<?php

/**
 * @file plugins/themes/custom/ArticleLoader.php
 *
 * Loads dynamic data for the custom theme article view page.
 */

namespace APP\plugins\themes\custom;

use APP\core\Application;
use PKP\plugins\Hook;
use PKP\publication\Publication;

class ArticleLoader
{
    public static function register(CustomThemePlugin $theme): void
    {
        Hook::add('TemplateManager::display', [self::class, 'loadArticleData']);
    }

    /**
     * @param array $args [TemplateManager, string &$template, mixed &$output]
     */
    public static function loadArticleData(string $hookName, array $args): bool
    {
        $templateMgr = $args[0];
        $template = $args[1];

        if ($template !== 'frontend/pages/article.tpl') {
            return Hook::CONTINUE;
        }

        $request = Application::get()->getRequest();
        if (!$request->getJournal()) {
            return Hook::CONTINUE;
        }

        $templateMgr->assign('isFullWidth', true);

        /** @var Publication|null $publication */
        $publication = $templateMgr->getTemplateVars('publication');

        $emptyAuthorsDisplay = [
            'authors' => [],
            'affiliations' => [],
        ];

        if (!$publication) {
            $templateMgr->assign('javsArticle', [
                'authorsDisplay' => $emptyAuthorsDisplay,
                'primaryContact' => null,
            ]);
            return Hook::CONTINUE;
        }

        $templateMgr->assign('javsArticle', [
            'authorsDisplay' => self::buildAuthorsDisplay($publication),
            'primaryContact' => self::getPrimaryContact($publication),
        ]);

        return Hook::CONTINUE;
    }

    /**
     * @return array{authors: array<int, array{name: string, affiliationIndices: array<int, int>, id: int, orcid: ?string, hasVerifiedOrcid: bool}>, affiliations: array<int, string>}
     */
    private static function buildAuthorsDisplay(Publication $publication): array
    {
        $authors = $publication->getData('authors') ?? [];
        $affiliationMap = [];
        $affiliations = [];
        $authorLines = [];

        foreach ($authors as $author) {
            $indices = [];
            foreach ($author->getAffiliations() as $affiliation) {
                $name = $affiliation->getLocalizedName();
                if ($name === null || $name === '') {
                    continue;
                }
                if (!array_key_exists($name, $affiliationMap)) {
                    $affiliationMap[$name] = count($affiliations) + 1;
                    $affiliations[] = $name;
                }
                $indices[] = $affiliationMap[$name];
            }

            $authorLines[] = [
                'name' => $author->getFullName(),
                'affiliationIndices' => array_values(array_unique($indices)),
                'orcid' => $author->getData('orcid'),
                'hasVerifiedOrcid' => $author->hasVerifiedOrcid(),
                'id' => $author->getId(),
            ];
        }

        return [
            'authors' => $authorLines,
            'affiliations' => $affiliations,
        ];
    }

    /**
     * @return array{name: string, orcid: ?string, hasVerifiedOrcid: bool, initials: string, affiliations: array<int, ?string>}|null
     */
    private static function getPrimaryContact(Publication $publication): ?array
    {
        $primaryContactId = $publication->getData('primaryContactId');
        if (!$primaryContactId) {
            return null;
        }

        foreach ($publication->getData('authors') as $author) {
            if ($author->getId() !== $primaryContactId) {
                continue;
            }

            return [
                'name' => $author->getFullName(),
                'orcid' => $author->getData('orcid'),
                'hasVerifiedOrcid' => $author->hasVerifiedOrcid(),
                'initials' => self::getInitials($author->getFullName()),
                'affiliations' => array_map(
                    fn ($affiliation) => $affiliation->getLocalizedName(),
                    $author->getAffiliations()
                ),
            ];
        }

        return null;
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
