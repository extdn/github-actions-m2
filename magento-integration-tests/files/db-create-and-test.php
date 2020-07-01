<?php
$database = $argv[1];
if (empty($database)) {
    throw new InvalidArgumentException('No database given');
}

$user = 'root';
$password = 'root';
$pdo = new PDO('mysql:host=127.0.0.1', $user, $password);
$pdo->query('CREATE DATABASE '.$database);

$stmt = $pdo->query('SHOW DATABASES');
$databases = $stmt->fetchAll(PDO::FETCH_COLUMN);
foreach($databases as $database){
    echo $database, "\n";
}

$pdo = new PDO('mysql:host=127.0.0.1;dbname='.$database, $user, $password);

