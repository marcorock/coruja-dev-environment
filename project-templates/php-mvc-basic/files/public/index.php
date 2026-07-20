<?php

declare(strict_types=1);

require dirname(__DIR__) . '/vendor/autoload.php';

use Dotenv\Dotenv;
use Twig\Environment;
use Twig\Loader\FilesystemLoader;

$dotenv = Dotenv::createImmutable(dirname(__DIR__));
$dotenv->safeLoad();

$loader = new FilesystemLoader(dirname(__DIR__) . '/templates');

$twig = new Environment($loader, [
    'cache' => false,
    'debug' => true,
]);

echo $twig->render('home.html.twig', [
    'projectName' => $_ENV['APP_NAME'] ?? 'Projeto PHP',
    'phpVersion' => PHP_VERSION,
]);