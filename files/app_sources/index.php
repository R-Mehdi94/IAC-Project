<?php
$servername = "localhost";
// $password = "UnAutreMotDePasseSolide";
// $dbname = "webapp_db";

// $mysql_root_password = "UnMotDePasseRootTresComplexe";
$db_name = "webapp_db";
$db_user = "webapp_user";
$db_password = "UnAutreMotDePasseSolide";

$conn = new mysqli($servername, $db_user, $db_password, $db_name);

if ($conn->connect_error) {
    echo "<h1> DÉPLOIEMENT RÉUSSI, MAIS...</h1>";
    echo "<p>La connexion à MySQL a échoué. Problème de réseau ou d'identifiants.</p>";
    die("Erreur: " . $conn->connect_error);
}


echo "<h1> Bienvenue à KapsuleKorp!</h1>";
echo "<h3>Infrastructure as Code (IaC) - Déploiement PHP-LEMP réussi!</h3>";
echo "<p>La base de données <strong>'$dbname'</strong> a été jointe avec succès!</p>";

$result = $conn->query("SELECT VERSION()");
$row = $result->fetch_row();
echo "<p>Version de MySQL: " . $row[0] . "</p>";

$conn->close();
