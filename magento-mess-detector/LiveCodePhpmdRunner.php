<?php

/**
 * Copyright © Magento, Inc. All rights reserved.
 * See COPYING.txt for license details.
 */

/**
 * PHP Code Mess v1.3.3 tool wrapper
 */

namespace Magento\TestFramework\CodingStandard\Tool;

use \Magento\TestFramework\CodingStandard\ToolInterface;

class LiveCodePhpmdRunner implements ToolInterface
{
    /**
     * Ruleset directory
     *
     * @var string
     */
    private $rulesetFile;

    /**
     * Report file
     *
     * @var string
     */
    private $reportFile;

    /**
     * Constructor
     *
     * @param string $rulesetDir \Directory that locates the inspection rules
     * @param string $reportFile Destination file to write inspection report to
     */
    public function __construct($rulesetFile, $reportFile)
    {
        $this->reportFile = $reportFile;
        $this->rulesetFile = $rulesetFile;
    }

    /**
     * Whether the tool can be ran on the current environment
     *
     * @return bool
     */
    public function canRun()
    {
        return class_exists(\PHPMD\TextUI\Command::class);
    }

    /**
     * {@inheritdoc}
     */
    public function run(array $whiteList)
    {
        $commandLineArguments = [
            'run_file_mock', //emulate script name in console arguments
            $this->getSourceCodePath($whiteList),
            'github', //report format
            $this->rulesetFile,
            '--reportfile',
            $this->reportFile,
            '--suffixes',
            'php',
            '--exclude',
            'vendor/,tmp/,var/,generated/,.git/,.idea/'
        ];

        $options = new \PHPMD\TextUI\CommandLineOptions($commandLineArguments);

        $command = new \PHPMD\TextUI\Command();

        return $command->run($options, new \PHPMD\RuleSetFactory());
    }

    private function getSourceCodePath($whiteList): string
    {
        if (!empty($whiteList)) {
            return implode(',', $whiteList);
        }
        return $_SERVER['GITHUB_WORKSPACE'] ?: '/var/www/html';
    }
}
