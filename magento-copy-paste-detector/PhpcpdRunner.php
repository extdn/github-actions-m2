<?php

/**
 * Copyright © Magento, Inc. All rights reserved.
 * See COPYING.txt for license details.
 */

declare(strict_types=1);

namespace Magento\Test\Php;

use Magento\TestFramework\CodingStandard\Tool\LiveCodePhpcpdRunner;

/**
 * Set of tests for static code analysis, e.g. code style, code complexity, copy paste detecting, etc.
 */
class PhpcpdRunner extends \PHPUnit\Framework\TestCase
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

    /**
     * Test code quality using phpcpd
     */
    public function testCopyPaste()
    {
        $reportFile = self::$reportDir . '/phpcpd_report.xml';
        $copyPasteDetector = new LiveCodePhpcpdRunner($reportFile);

        if (!$copyPasteDetector->canRun()) {
            $this->markTestSkipped('PHP Copy/Paste Detector is not available.');
        }

        $blackList = [];
        foreach (glob(__DIR__ . '/_files/phpcpd/blacklist/*.txt') as $list) {
            $blackList[] = file($list, FILE_IGNORE_NEW_LINES);
        }
        $blackList = array_merge([], ...$blackList);

        $copyPasteDetector->setBlackList($blackList);

        $result = $copyPasteDetector->run([]);

        $output = file_exists($reportFile) ? file_get_contents($reportFile) : '';

        $this->assertTrue(
            $result,
            "PHP Copy/Paste Detector has found error(s):" . PHP_EOL . $output
        );
    }
}
