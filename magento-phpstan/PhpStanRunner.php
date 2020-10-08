<?php
/**
 * Copyright © Magento, Inc. All rights reserved.
 * See COPYING.txt for license details.
 */
declare(strict_types=1);

namespace Magento\Test\Php;

use Magento\Framework\App\Utility\Files;
use Magento\TestFramework\CodingStandard\Tool\LiveCodePhpStanRunner;

/**
 * Set of tests for static code analysis, e.g. code style, code complexity, copy paste detecting, etc.
 */
class PhpStanRunner extends \PHPUnit\Framework\TestCase
{
    /**
     * @var string
     */
    protected static $reportDir = '';

    /**
     * @var string
     */
    protected static $pathToSource = '';

    /**
     * Setup basics for all tests
     *
     * @return void
     */
    public static function setUpBeforeClass(): void
    {
        self::$pathToSource = BP;
        self::$reportDir = self::$pathToSource . '/dev/tests/static/report';
        if (!is_dir(self::$reportDir)) {
            mkdir(self::$reportDir);
        }
    }

    public function testPhpStan()
    {
        $reportFile = self::$reportDir . '/phpstan_report.txt';
        $confFile = __DIR__ . '/_files/phpstan/phpstan.neon';

        if (!file_exists($reportFile)) {
            touch($reportFile);
        }

        $phpStan = new LiveCodePhpStanRunner($confFile, $reportFile);
        $exitCode = $phpStan->run([]);
        $report = file_get_contents($reportFile);

        $errorMessage = empty($report) ?
            'PHPStan command run failed.' : 'PHPStan detected violation(s):' . PHP_EOL . $report;
        $this->assertEquals(0, $exitCode, $errorMessage);

        // delete empty reports
        if (file_exists($reportFile)) {
            unlink($reportFile);
        }
    }

}

