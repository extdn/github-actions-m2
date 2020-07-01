<?php
$disableModules = [];
$allModules = include(__DIR__ . '/../../../app/etc/config.php');
foreach ($allModules as $allModule => $allModuleValue) {
    if ($allModuleValue === 0) {
        $disableModules[] = $allModule;
    }
}

return [
    'db-host' => 'mysql',
    'db-user' => 'root',
    'db-password' => 'root',
    'db-name' => 'magento2',
    'db-prefix' => '',
    'backend-frontname' => 'backend',
    'admin-user' => \Magento\TestFramework\Bootstrap::ADMIN_NAME,
    'admin-password' => \Magento\TestFramework\Bootstrap::ADMIN_PASSWORD,
    'admin-email' => \Magento\TestFramework\Bootstrap::ADMIN_EMAIL,
    'admin-firstname' => \Magento\TestFramework\Bootstrap::ADMIN_FIRSTNAME,
    'admin-lastname' => \Magento\TestFramework\Bootstrap::ADMIN_LASTNAME,
    'disable_modules' => implode(',', $disableModules)
];
