<?php
$database = $argv[1];
if (empty($database)) {
    throw new InvalidArgumentException('No database given');
}

$user = 'root';
$password = 'root';
$pdo = new PDO('mysql:host=mysql', $user, $password);
$pdo->query('CREATE DATABASE '.$database);

$pdo = new PDO('mysql:host=mysql;dbname='.$database, $user, $password);

