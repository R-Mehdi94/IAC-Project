<?php
$serverName = "34.63.79.70";
$dbUser = "webapp_user";
$dbPassword = "UnAutreMotDePasseSolide";
$dbName = "webapp_db";

$dbConnection = new mysqli($serverName, $dbUser, $dbPassword, $dbName);

if ($dbConnection->connect_error) {
    echo "<h1>DEPLOY SUCCESSFUL BUT...</h1>";
    echo "<p>The connection with MySQL has failed. Error with network or credentials.</p>";
    die("Error: " . $dbConnection->connect_error);
}


echo "<h1>Welcome to KapsuleKorp!</h1>";
echo "<h3>Infrastructure as Code - Deployment PHP-LEMP successful!</h3>";
echo "<p>The database <strong>'$dbname'</strong> is connected!</p>";

$result = $dbConnection->query("SELECT VERSION()");
$row = $result->fetch_row();
echo "<p>MySQL version: " . $row[0] . "</p>";

$dbConnection->close();
