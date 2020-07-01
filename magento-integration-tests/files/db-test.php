<?php
$user = 'root';
$password = 'root';
$pdo = new PDO('mysql:host=127.0.0.1', $user, $password);
$pdo->query('CREATE DATABASE magento2');
$pdo = new PDO('mysql:host=127.0.0.1;dbname=magento2', $user, $password);

