<?php
return [
    'db-host' => 'mysql',
    'db-user' => 'root',
    'db-password' => 'root',
    'db-name' => 'magento2test',
    'db-prefix' => '',
    'backend-frontname' => 'backend',
    'admin-user' => \Magento\TestFramework\Bootstrap::ADMIN_NAME,
    'admin-password' => \Magento\TestFramework\Bootstrap::ADMIN_PASSWORD,
    'admin-email' => \Magento\TestFramework\Bootstrap::ADMIN_EMAIL,
    'admin-firstname' => \Magento\TestFramework\Bootstrap::ADMIN_FIRSTNAME,
    'admin-lastname' => \Magento\TestFramework\Bootstrap::ADMIN_LASTNAME,
    'search-engine' => '{{SEARCH_ENGINE_VERSION}}',
    'elasticsearch-host' => 'es',
    'elasticsearch-port' => '9200',
];
