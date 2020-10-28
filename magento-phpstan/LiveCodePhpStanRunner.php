<?php
/**
 * Copyright © Magento, Inc. All rights reserved.
 * See COPYING.txt for license details.
 */
declare(strict_types=1);

namespace Magento\TestFramework\CodingStandard\Tool;

use Magento\TestFramework\CodingStandard\ToolInterface;

/**
 * PhpStan tool wrapper.
 */
class LiveCodePhpStanRunner implements ToolInterface
{
    /**
     * Rule level to be used.
     *
     * @see https://github.com/phpstan/phpstan#rule-levels
     */
    private const RULE_LEVEL = 1;

    /**
     * Memory limit required by PHPStan for full Magento project scan.
     */
    private const MEMORY_LIMIT = '4G';

    /**
     * Error formatter to be used.
     *
     * @see https://github.com/phpstan/phpstan#existing-error-formatters-to-be-used
     */
    private const ERROR_FORMAT = 'raw';

    /**
     * Report file.
     *
     * @var string
     */
    private $reportFile;

    /**
     * PHPStan configuration file in neon format.
     *
     * @var string
     */
    private $confFile;

    /**
     * @param string $confFile
     * @param string $reportFile
     */
    public function __construct(string $confFile, string $reportFile)
    {
        $this->reportFile = $reportFile;
        $this->confFile = $confFile;
    }

    /**
     * @inheritdoc
     * @SuppressWarnings(PHPMD.UnusedLocalVariable)
     */
    public function canRun(): bool
    {
        // phpcs:disable Magento2.Security.InsecureFunction
        exec($this->getCommand() . ' --version', $output, $exitCode);
        return $exitCode === 0;
    }

    /**
     * @inheritdoc
     * @SuppressWarnings(PHPMD.UnusedLocalVariable)
     */
    public function run(array $whiteList): int
    {

        $command = $this->getCommand() . ' analyse' .
            ' --level ' . self::RULE_LEVEL .
            ' --no-progress' .
            ' --error-format=' . self::ERROR_FORMAT .
            ' --memory-limit=' . self::MEMORY_LIMIT .
            // phpcs:ignore Magento2.Functions.DiscouragedFunction
            ' --configuration ' . escapeshellarg($this->confFile) .
            ' ' . $this->getSourceCodePath($whiteList).
            ' > ' . $this->reportFile;

        // phpcs:disable Magento2.Security.InsecureFunction
        exec($command, $output, $exitCode);
echo $command;
        passthru($command);
        echo "Exit Code".$exitCode;
        return $exitCode;
    }

    /**
     * Get PHPStan CLI command
     *
     * @return string
     */
    private function getCommand(): string
    {
        // phpcs:ignore Magento2.Security.IncludeFile
        $vendorDir = require BP . '/app/etc/vendor_path.php';
        return 'php ' . BP . '/' . $vendorDir . '/bin/phpstan';
    }

    private function getSourceCodePath($whiteList): string
    {
        if(!empty($whiteList)){
            return implode(',', $whiteList);
        }
        return defined('PATH_TO_SOURCE')? PATH_TO_SOURCE : '/var/www/html';
    }

}
