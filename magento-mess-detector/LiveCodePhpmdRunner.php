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
        $command = $this->createCommand();

        // PHPMD 3 turned the command into a Symfony console command and dropped the array based
        // CommandLineOptions constructor. Images that build Magento 2.4.7 still install PHPMD 2
        // (it pins phpmd/phpmd ^2.12), so both APIs have to keep working.
        if ($command instanceof \Symfony\Component\Console\Command\Command) {
            $input = new \Symfony\Component\Console\Input\ArrayInput(
                [
                    'paths' => explode(',', $this->getSourceCodePath($whiteList)),
                    '--format' => 'github',
                    '--ruleset' => [$this->rulesetFile],
                    '--reportfile-github' => $this->reportFile,
                    '--suffixes' => ['php'],
                    '--exclude' => ['vendor/', 'tmp/', 'var/', 'generated/', '.git/', '.idea/'],
                ],
                $command->getDefinition()
            );

            return $command->run($input, new \Symfony\Component\Console\Output\NullOutput());
        }

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

        return $command->run($options, new \PHPMD\RuleSetFactory());
    }

    /**
     * PHPMD 2.15 made the command require a \PHPMD\Console\Output, PHPMD 3 takes no arguments.
     *
     * @return \PHPMD\TextUI\Command
     */
    private function createCommand()
    {
        $constructor = (new \ReflectionClass(\PHPMD\TextUI\Command::class))->getConstructor();

        if ($constructor !== null && $constructor->getNumberOfRequiredParameters() > 0) {
            return new \PHPMD\TextUI\Command(new \PHPMD\Console\NullOutput());
        }

        return new \PHPMD\TextUI\Command();
    }

    private function getSourceCodePath($whiteList): string
    {
        if (!empty($whiteList)) {
            return implode(',', $whiteList);
        }
        return $_SERVER['GITHUB_WORKSPACE'] ?: '/var/www/html';
    }
}
