<?php

/**
 * @file plugins/themes/custom/IndexedDatabaseHelper.php
 *
 * Parses and serializes homepage indexed-database entries for admin + frontend.
 */

namespace APP\plugins\themes\custom;

class IndexedDatabaseHelper
{
    /**
     * @return array<string, array{name: string, url: string, logo: string}>
     */
    public static function knownDatabases(): array
    {
        return [
            'crossref' => [
                'name' => 'CrossRef',
                'url' => 'https://www.crossref.org/',
                'logo' => 'crossref',
            ],
            'semantic-scholar' => [
                'name' => 'Semantic Scholar',
                'url' => 'https://www.semanticscholar.org/',
                'logo' => 'semantic-scholar',
            ],
            'google-scholar' => [
                'name' => 'Google Scholar',
                'url' => 'https://scholar.google.com/',
                'logo' => 'google-scholar',
            ],
            'dimensions' => [
                'name' => 'Dimensions',
                'url' => 'https://www.dimensions.ai/',
                'logo' => 'dimensions',
            ],
            'base' => [
                'name' => 'BASE',
                'url' => 'https://www.base-search.net/',
                'logo' => 'base',
            ],
            'road' => [
                'name' => 'ROAD',
                'url' => 'https://road.issn.org/',
                'logo' => 'road',
            ],
            'ici-world-of-journals' => [
                'name' => 'ICI World of Journals',
                'url' => 'https://journals.indexcopernicus.com/',
                'logo' => 'ici',
            ],
            'europub' => [
                'name' => 'EuroPub',
                'url' => 'https://europub.co.uk/',
                'logo' => 'europub',
            ],
            'scispace' => [
                'name' => 'SciSpace',
                'url' => 'https://scispace.com/',
                'logo' => 'scispace',
            ],
            'r-discovery' => [
                'name' => 'R Discovery',
                'url' => 'https://discovery.researcher.life/',
                'logo' => 'r-discovery',
            ],
        ];
    }

    /**
     * @return array<int, array{name: string, url: string, logo: string}>
     */
    public static function defaultEntries(): array
    {
        return array_values(self::knownDatabases());
    }

    /**
     * @return array<int, array{name: string, url: string|null, logoUrl: string}>
     */
    public static function parse(mixed $raw, string $assetBaseUrl): array
    {
        $entries = [];
        foreach (self::decodeEntries($raw) as $entry) {
            $name = $entry['name'];
            $url = $entry['url'] !== '' ? $entry['url'] : null;
            $logoKey = $entry['logo'] !== '' ? $entry['logo'] : self::slugify($name);
            $logoFile = self::resolveLogoFile($logoKey);

            $entries[] = [
                'name' => $name,
                'url' => $url,
                'logoUrl' => rtrim($assetBaseUrl, '/') . '/img/indexed/' . $logoFile,
            ];
        }

        return $entries;
    }

    /**
     * @return array<int, array{name: string, url: string, logo: string}>
     */
    public static function decodeEntries(mixed $raw): array
    {
        if (is_array($raw)) {
            return self::normalizeEntries($raw);
        }

        $raw = trim((string) $raw);
        if ($raw === '') {
            return [];
        }

        if (str_starts_with($raw, '[') && str_contains($raw, '{')) {
            try {
                $decoded = json_decode($raw, true, 512, JSON_THROW_ON_ERROR);
                if (is_array($decoded)) {
                    return self::normalizeEntries($decoded);
                }
            } catch (\JsonException) {
                // Fall through to other formats.
            }
        }

        if (str_contains($raw, "url =") || preg_match('/^\[[^\]]+\]/m', $raw)) {
            return self::parseAdminBlocks($raw);
        }

        return self::parseLegacyLines($raw);
    }

    /**
     * @param array<int, mixed> $entries
     * @return array<int, array{name: string, url: string, logo: string}>
     */
    public static function normalizeEntries(array $entries): array
    {
        $known = self::knownDatabases();
        $normalized = [];

        foreach ($entries as $entry) {
            if (!is_array($entry)) {
                continue;
            }

            $name = trim((string) ($entry['name'] ?? ''));
            if ($name === '') {
                continue;
            }

            $url = trim((string) ($entry['url'] ?? ''));
            $logo = trim((string) ($entry['logo'] ?? ''));
            $slug = self::slugify($name);

            if ($url === '' && isset($known[$slug])) {
                $url = $known[$slug]['url'];
            }
            if ($logo === '' && isset($known[$slug])) {
                $logo = $known[$slug]['logo'];
            }
            if ($logo === '') {
                $logo = $slug;
            }

            $normalized[] = [
                'name' => $name,
                'url' => $url,
                'logo' => $logo,
            ];
        }

        return $normalized;
    }

    public static function parseAdminBlocks(string $raw): array
    {
        $entries = [];
        $blocks = preg_split('/\n\s*\n/u', trim($raw)) ?: [];

        foreach ($blocks as $block) {
            $block = trim($block);
            if ($block === '') {
                continue;
            }

            $name = '';
            $url = '';
            $logo = '';

            if (preg_match('/^\[([^\]]+)\]\s*(.*)$/su', $block, $matches)) {
                $name = trim($matches[1]);
                $block = trim($matches[2]);
            }

            foreach (preg_split('/\r\n|\r|\n/u', $block) as $line) {
                $line = trim($line);
                if ($line === '') {
                    continue;
                }

                if (preg_match('/^(?:url|link)\s*=\s*(.+)$/iu', $line, $lineMatch)) {
                    $url = trim($lineMatch[1]);
                    continue;
                }

                if (preg_match('/^logo\s*=\s*(.+)$/iu', $line, $lineMatch)) {
                    $logo = trim($lineMatch[1]);
                    continue;
                }

                if ($name === '' && !str_contains($line, '=')) {
                    $name = $line;
                }
            }

            if ($name === '') {
                continue;
            }

            $entries[] = [
                'name' => $name,
                'url' => $url,
                'logo' => $logo,
            ];
        }

        return self::normalizeEntries($entries);
    }

    public static function parseLegacyLines(string $raw): array
    {
        $entries = [];

        foreach (preg_split('/\r\n|\r|\n/u', $raw) as $line) {
            $line = trim($line);
            if ($line === '') {
                continue;
            }

            $parts = array_map('trim', explode('|', $line));
            $entries[] = [
                'name' => $parts[0],
                'url' => $parts[1] ?? '',
                'logo' => $parts[2] ?? '',
            ];
        }

        return self::normalizeEntries($entries);
    }

    /**
     * @param array<int, array{name: string, url: string, logo: string}> $entries
     */
    public static function encodeForStorage(array $entries): string
    {
        return json_encode(
            self::normalizeEntries($entries),
            JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR
        );
    }

    /**
     * @param array<int, array{name: string, url: string, logo: string}> $entries
     */
    public static function serializeForAdmin(array $entries): string
    {
        $entries = self::normalizeEntries($entries);
        if (!$entries) {
            return self::serializeForAdmin(self::defaultEntries());
        }

        $blocks = [];
        foreach ($entries as $entry) {
            $blocks[] = implode("\n", [
                '[' . $entry['name'] . ']',
                'url = ' . $entry['url'],
                'logo = ' . $entry['logo'],
            ]);
        }

        return implode("\n\n", $blocks);
    }

    /**
     * @return array<int, string> Logo keys without .svg extension
     */
    public static function getAvailableLogos(): array
    {
        $logos = [];
        $directory = __DIR__ . '/img/indexed';
        if (!is_dir($directory)) {
            return $logos;
        }

        foreach (scandir($directory) ?: [] as $file) {
            if (!str_ends_with(strtolower($file), '.svg')) {
                continue;
            }
            $logos[] = substr($file, 0, -4);
        }

        sort($logos);

        return $logos;
    }

    public static function getAdminHelpHtml(): string
    {
        $logoItems = array_map(
            fn (string $logo) => '<code>' . htmlspecialchars($logo, ENT_QUOTES, 'UTF-8') . '</code>',
            self::getAvailableLogos()
        );

        $presetRows = '';
        foreach (self::knownDatabases() as $preset) {
            $presetRows .= '<tr>'
                . '<td>' . htmlspecialchars($preset['name'], ENT_QUOTES, 'UTF-8') . '</td>'
                . '<td><code>' . htmlspecialchars($preset['logo'], ENT_QUOTES, 'UTF-8') . '</code></td>'
                . '</tr>';
        }

        return '<div class="javs_indexed_admin_help">'
            . '<p><strong>' . htmlspecialchars(__('plugins.themes.custom.option.homepageIndexedDatabases.helpIntro'), ENT_QUOTES, 'UTF-8') . '</strong></p>'
            . '<pre>[CrossRef]
url = https://www.crossref.org/
logo = crossref

[Semantic Scholar]
url = https://www.semanticscholar.org/
logo = semantic-scholar</pre>'
            . '<p>' . htmlspecialchars(__('plugins.themes.custom.option.homepageIndexedDatabases.helpFields'), ENT_QUOTES, 'UTF-8') . '</p>'
            . '<ul>'
            . '<li>' . htmlspecialchars(__('plugins.themes.custom.option.homepageIndexedDatabases.helpName'), ENT_QUOTES, 'UTF-8') . '</li>'
            . '<li>' . htmlspecialchars(__('plugins.themes.custom.option.homepageIndexedDatabases.helpUrl'), ENT_QUOTES, 'UTF-8') . '</li>'
            . '<li>' . htmlspecialchars(__('plugins.themes.custom.option.homepageIndexedDatabases.helpLogo'), ENT_QUOTES, 'UTF-8') . '</li>'
            . '</ul>'
            . '<p><strong>' . htmlspecialchars(__('plugins.themes.custom.option.homepageIndexedDatabases.helpLogosTitle'), ENT_QUOTES, 'UTF-8') . '</strong> '
            . implode(', ', $logoItems)
            . '</p>'
            . '<p>' . htmlspecialchars(__('plugins.themes.custom.option.homepageIndexedDatabases.helpCustomLogo'), ENT_QUOTES, 'UTF-8') . '</p>'
            . '<table class="pkpTable">'
            . '<thead><tr><th>' . htmlspecialchars(__('common.name'), ENT_QUOTES, 'UTF-8') . '</th><th>' . htmlspecialchars(__('plugins.themes.custom.option.homepageIndexedDatabases.helpLogoKey'), ENT_QUOTES, 'UTF-8') . '</th></tr></thead>'
            . '<tbody>' . $presetRows . '</tbody>'
            . '</table>'
            . '</div>';
    }

    public static function slugify(string $name): string
    {
        $slug = strtolower($name);
        $slug = preg_replace('/[^a-z0-9]+/', '-', $slug);

        return trim((string) $slug, '-');
    }

    private static function resolveLogoFile(string $logoKey): string
    {
        $logoKey = self::slugify($logoKey);
        $path = __DIR__ . '/img/indexed/' . $logoKey . '.svg';

        return file_exists($path) ? $logoKey . '.svg' : 'generic.svg';
    }
}
