<?php

/**
 * @file plugins/themes/custom/HomepageRecentArticlesHandler.php
 *
 * AJAX endpoint for homepage recent articles load-more.
 */

namespace APP\plugins\themes\custom;

use APP\core\Application;
use APP\handler\Handler;
use APP\journal\Journal;
use APP\security\authorization\OjsJournalMustPublishPolicy;
use PKP\core\JSONMessage;

class HomepageRecentArticlesHandler extends Handler
{
    public function __construct(private CustomThemePlugin $theme)
    {
        parent::__construct();
    }

    /**
     * @copydoc Handler::authorize()
     */
    public function authorize($request, &$args, $roleAssignments)
    {
        if ($request->getContext()) {
            $this->addPolicy(new OjsJournalMustPublishPolicy($request));
        }

        return parent::authorize($request, $args, $roleAssignments);
    }

    /**
     * Return the next batch of recent article cards as JSON.
     *
     * @param array $args
     * @param \APP\core\Request $request
     */
    public function recentArticles($args, $request): JSONMessage
    {
        $this->validate(null, $request);
        $this->setupTemplate($request);

        $journal = $request->getJournal();
        if (!$journal instanceof Journal || !$this->theme->isActive()) {
            return new JSONMessage(false);
        }

        $offset = max(0, (int) $request->getUserVar('offset'));
        $batchSize = HomepageLoader::getRecentArticlesBatchSize($this->theme);
        $result = HomepageLoader::renderRecentArticleCards($journal, $this->theme, $offset, $batchSize);

        $loadedCount = $result['count'];
        $nextOffset = $offset + $loadedCount;
        $publishedCount = HomepageLoader::getPublishedArticleCount($journal->getId());

        return new JSONMessage(true, '', '0', [
            'html' => $result['html'],
            'hasMore' => $nextOffset < $publishedCount,
            'nextOffset' => $nextOffset,
        ]);
    }
}
