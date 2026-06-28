<?php

/**
 * @file plugins/themes/custom/CustomThemePlugin.php
 *
 * Copyright (c) 2014-2021 Simon Fraser University
 * Copyright (c) 2003-2021 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @class CustomThemePlugin
 *
 * @brief Custom theme based on the default OJS theme
 */

namespace APP\plugins\themes\custom;

require_once __DIR__ . '/HomepageLoader.php';
require_once __DIR__ . '/IssueLoader.php';
require_once __DIR__ . '/ArchiveLoader.php';
require_once __DIR__ . '/ArticleLoader.php';

use APP\core\Application;
use APP\file\PublicFileManager;
use PKP\config\Config;
use PKP\core\PKPSessionGuard;

class CustomThemePlugin extends \PKP\plugins\ThemePlugin
{
    /**
     * @copydoc ThemePlugin::isActive()
     */
    public function isActive()
    {
        if (PKPSessionGuard::isSessionDisable()) {
            return true;
        }
        return parent::isActive();
    }

    /**
     * Initialize the theme's styles, scripts and hooks. This is run on the
     * currently active theme and it's parent themes.
     *
     */
    public function init()
    {
        // Register theme options
        $this->addOption('typography', 'FieldOptions', [
            'type' => 'radio',
            'label' => __('plugins.themes.custom.option.typography.label'),
            'description' => __('plugins.themes.custom.option.typography.description'),
            'options' => [
                [
                    'value' => 'notoSans',
                    'label' => __('plugins.themes.custom.option.typography.notoSans'),
                ],
                [
                    'value' => 'notoSerif',
                    'label' => __('plugins.themes.custom.option.typography.notoSerif'),
                ],
                [
                    'value' => 'notoSerif_notoSans',
                    'label' => __('plugins.themes.custom.option.typography.notoSerif_notoSans'),
                ],
                [
                    'value' => 'notoSans_notoSerif',
                    'label' => __('plugins.themes.custom.option.typography.notoSans_notoSerif'),
                ],
                [
                    'value' => 'lato',
                    'label' => __('plugins.themes.custom.option.typography.lato'),
                ],
                [
                    'value' => 'lora',
                    'label' => __('plugins.themes.custom.option.typography.lora'),
                ],
                [
                    'value' => 'lora_openSans',
                    'label' => __('plugins.themes.custom.option.typography.lora_openSans'),
                ],
            ],
            'default' => 'lora_openSans',
        ]);

        $this->addOption('baseColour', 'FieldColor', [
            'label' => __('plugins.themes.custom.option.colour.label'),
            'description' => __('plugins.themes.custom.option.colour.description'),
            'default' => '#6d2d3d',
        ]);

        $this->addOption('headerFooterColour', 'FieldColor', [
            'label' => __('plugins.themes.custom.option.headerFooterColour.label'),
            'description' => __('plugins.themes.custom.option.headerFooterColour.description'),
            'default' => '#4a1d28',
        ]);

        $this->addOption('showDescriptionInJournalIndex', 'FieldOptions', [
            'label' => __('manager.setup.contextSummary'),
            'options' => [
                [
                    'value' => true,
                    'label' => __('plugins.themes.custom.option.showDescriptionInJournalIndex.option'),
                ],
            ],
            'default' => false,
        ]);
        $this->addOption('useHomepageImageAsHeader', 'FieldOptions', [
            'label' => __('plugins.themes.custom.option.useHomepageImageAsHeader.label'),
            'description' => __('plugins.themes.custom.option.useHomepageImageAsHeader.description'),
            'options' => [
                [
                    'value' => true,
                    'label' => __('plugins.themes.custom.option.useHomepageImageAsHeader.option')
                ],
            ],
            'default' => false,
        ]);
        $this->addOption('displayStats', 'FieldOptions', [
            'type' => 'radio',
            'label' => __('plugins.themes.custom.option.displayStats.label'),
            'options' => [
                [
                    'value' => 'none',
                    'label' => __('plugins.themes.custom.option.displayStats.none'),
                ],
                [
                    'value' => 'bar',
                    'label' => __('plugins.themes.custom.option.displayStats.bar'),
                ],
                [
                    'value' => 'line',
                    'label' => __('plugins.themes.custom.option.displayStats.line'),
                ],
            ],
            'default' => 'none',
        ]);

        $this->addOption('homepageStatsReviewTime', 'FieldText', [
            'label' => __('plugins.themes.custom.option.homepageStatsReviewTime.label'),
            'description' => __('plugins.themes.custom.option.homepageStatsReviewTime.description'),
            'default' => '8–12 wk',
        ]);

        $this->addOption('homepageIndexedDatabases', 'FieldTextarea', [
            'label' => __('plugins.themes.custom.option.homepageIndexedDatabases.label'),
            'description' => __('plugins.themes.custom.option.homepageIndexedDatabases.description'),
            'default' => "CrossRef\nSemantic Scholar\nGoogle Scholar\nDimensions\nBASE\nROAD\nICI World of Journals\nEuroPub\nSciSpace\nR Discovery",
        ]);

        $this->addOption('homepageRecentArticlesCount', 'FieldText', [
            'label' => __('plugins.themes.custom.option.homepageRecentArticlesCount.label'),
            'description' => __('plugins.themes.custom.option.homepageRecentArticlesCount.description'),
            'default' => '6',
        ]);

        $this->addOption('homepageMastheadLimit', 'FieldText', [
            'label' => __('plugins.themes.custom.option.homepageMastheadLimit.label'),
            'description' => __('plugins.themes.custom.option.homepageMastheadLimit.description'),
            'default' => '5',
        ]);

        HomepageLoader::register($this);
        IssueLoader::register($this);
        ArchiveLoader::register($this);
        ArticleLoader::register($this);
        $this->addStyle('stylesheet', 'styles/index.less');

        // Store additional LESS variables to process based on options
        $additionalLessVariables = [];

        if ($this->getOption('typography') === 'notoSerif') {
            $this->addStyle('font', 'styles/fonts/notoSerif.less');
            $additionalLessVariables[] = '@font: "Noto Serif", -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Oxygen-Sans", "Ubuntu", "Cantarell", "Helvetica Neue", sans-serif;';
        } elseif (strpos($this->getOption('typography'), 'notoSerif') !== false) {
            $this->addStyle('font', 'styles/fonts/notoSans_notoSerif.less');
            if ($this->getOption('typography') == 'notoSerif_notoSans') {
                $additionalLessVariables[] = '@font-heading: "Noto Serif", serif;';
            } elseif ($this->getOption('typography') == 'notoSans_notoSerif') {
                $additionalLessVariables[] = '@font: "Noto Serif", serif;@font-heading: "Noto Sans", serif;';
            }
        } elseif ($this->getOption('typography') == 'lato') {
            $this->addStyle('font', 'styles/fonts/lato.less');
            $additionalLessVariables[] = '@font: Lato, sans-serif;';
        } elseif ($this->getOption('typography') == 'lora') {
            $this->addStyle('font', 'styles/fonts/lora.less');
            $additionalLessVariables[] = '@font: Lora, serif;';
        } elseif ($this->getOption('typography') == 'lora_openSans') {
            $this->addStyle('font', 'styles/fonts/lora_openSans.less');
            // Use Inter (Google Fonts) as body font alongside self-hosted Lora headings
            $additionalLessVariables[] = '@font: "Inter", "Open Sans", system-ui, sans-serif;@font-heading: Lora, serif;';
        } else {
            $this->addStyle('font', 'styles/fonts/notoSans.less');
        }

        // Theme colours — accent (nav, links) and header/footer bar
        $baseColour = $this->getOption('baseColour');
        if (!preg_match('/^#[0-9a-fA-F]{1,6}$/', $baseColour)) {
            $baseColour = '#6d2d3d';
        }
        $headerFooterColour = $this->getOption('headerFooterColour');
        if (!preg_match('/^#[0-9a-fA-F]{1,6}$/', $headerFooterColour)) {
            $headerFooterColour = '#4a1d28';
        }
        $additionalLessVariables[] = '@bg-base:' . $baseColour . ';';
        $additionalLessVariables[] = '@bg-bar:' . $headerFooterColour . ';';
        $additionalLessVariables[] = '@bg-base-dark:' . $headerFooterColour . ';';
        if (!$this->isColourDark($baseColour)) {
            $additionalLessVariables[] = '@text-bg-base:rgba(0,0,0,0.84);';
            $additionalLessVariables[] = '@bg-base-border-color:rgba(0,0,0,0.2);';
        }

        $this->addStyle(
            'themeColourVars',
            ':root{--pkp-bg-base:' . $baseColour . ';--pkp-bg-bar:' . $headerFooterColour . ';--pkp-bg-base-light:' . $this->lightenHex($baseColour, 12) . ';}',
            ['inline' => true]
        );

        // Load primary stylesheet
        if (!empty($additionalLessVariables)) {
            $this->modifyStyle('stylesheet', ['addLessVariables' => join("\n", $additionalLessVariables)]);
        }

        $request = Application::get()->getRequest();

        // Load Google Fonts: Inter (body) + Lora (headings) for JAVS aesthetic
        // Loaded regardless of typography option so Inter is always available as fallback.
        $this->addStyle(
            'javsFonts',
            'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Lora:ital,wght@0,600;1,400&family=Noto+Serif+SC:wght@500;600&display=swap',
            ['baseUrl' => '']
        );

        // Load icon font FontAwesome - http://fontawesome.io/
        $this->addStyle(
            'fontAwesome',
            $request->getBaseUrl() . '/lib/pkp/styles/fontawesome/fontawesome.css',
            ['baseUrl' => '']
        );

        // Get homepage image and use as header background if useAsHeader is true
        $context = Application::get()->getRequest()->getContext();
        if ($context && $this->getOption('useHomepageImageAsHeader') && ($homepageImage = $context->getLocalizedData('homepageImage'))) {
            $publicFileManager = new PublicFileManager();
            $publicFilesDir = $request->getBaseUrl() . '/' . $publicFileManager->getContextFilesPath($context->getId());
            $homepageImageUrl = $publicFilesDir . '/' . $homepageImage['uploadName'];

            $this->addStyle(
                'homepageImage',
                '.javs_navbar { background: center / cover no-repeat url("' . $homepageImageUrl . '");}',
                ['inline' => true]
            );
        }

        // Load jQuery from a CDN or, if CDNs are disabled, from a local copy.
        $min = Config::getVar('general', 'enable_minified') ? '.min' : '';
        $jquery = $request->getBaseUrl() . '/js/build/jquery/jquery' . $min . '.js';
        $jqueryUI = $request->getBaseUrl() . '/js/build/jquery-ui/jquery-ui' . $min . '.js';

        // Use an empty `baseUrl` argument to prevent the theme from looking for
        // the files within the theme directory
        $this->addScript('jQuery', $jquery, ['baseUrl' => '']);
        $this->addScript('jQueryUI', $jqueryUI, ['baseUrl' => '']);

        // Load Bootsrap's dropdown
        $this->addScript('popper', 'js/lib/popper/popper.js');
        $this->addScript('bsUtil', 'js/lib/bootstrap/util.js');
        $this->addScript('bsDropdown', 'js/lib/bootstrap/dropdown.js');

        // Load Swiper for carousel
        $this->addScript('swiper', 'js/lib/swiper/swiper-bundle' . $min . '.js');
        $this->addStyle('swiper', 'js/lib/swiper/swiper-bundle' . $min . '.css');
        $this->addScript('swiper-i18n', $this->getSwiperI18n(), ['inline' => true]);

        // Load custom JavaScript for this theme
        $this->addScript('custom', 'js/main.js');

        // Add navigation menu areas for this theme
        $this->addMenuArea(['primary', 'user']);
    }

    /**
     * Get the name of the settings file to be installed on new journal
     * creation.
     *
     * @return string
     */
    public function getContextSpecificPluginSettingsFile()
    {
        return $this->getPluginPath() . '/settings.xml';
    }

    /** @see ThemePlugin::saveOption */
    public function saveOption($name, $value, $contextId = null) {
        // Validate the base colour setting value (pkp/pkp-lib#11974).
        if (in_array($name, ['baseColour', 'headerFooterColour'], true) && !preg_match('/^#[0-9a-fA-F]{1,6}$/', $value)) {
            $value = null;
        }

        parent::saveOption($name, $value, $contextId);
    }

    /**
     * Get the name of the settings file to be installed site-wide when
     * OJS is installed.
     *
     * @return string
     */
    public function getInstallSitePluginSettingsFile()
    {
        return $this->getPluginPath() . '/settings.xml';
    }

    /**
     * Get the display name of this plugin
     *
     * @return string
     */
    public function getDisplayName()
    {
        return __('plugins.themes.custom.name');
    }

    /**
     * Get the description of this plugin
     *
     * @return string
     */
    public function getDescription()
    {
        return __('plugins.themes.custom.description');
    }

    /**
     * Get the locale strings for the swiper carousel
     */
    public function getSwiperI18n(): string
    {
        return 'var pkpCustomThemeI18N = ' . json_encode([
            'nextSlide' => __('plugins.themes.custom.nextSlide'),
            'prevSlide' => __('plugins.themes.custom.prevSlide'),
        ]);
    }

    /**
     * Lighten a hex colour by a percentage for CSS custom properties.
     */
    protected function lightenHex(string $color, int $percent): string
    {
        $color = ltrim($color, '#');
        if (strlen($color) === 3) {
            $color = $color[0] . $color[0] . $color[1] . $color[1] . $color[2] . $color[2];
        }
        $r = min(255, hexdec(substr($color, 0, 2)) + round(255 * ($percent / 100)));
        $g = min(255, hexdec(substr($color, 2, 2)) + round(255 * ($percent / 100)));
        $b = min(255, hexdec(substr($color, 4, 2)) + round(255 * ($percent / 100)));
        return sprintf('#%02x%02x%02x', $r, $g, $b);
    }
}

if (!PKP_STRICT_MODE) {
    class_alias('\APP\plugins\themes\custom\CustomThemePlugin', '\CustomThemePlugin');
}
