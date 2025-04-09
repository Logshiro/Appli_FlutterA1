<?php
require_once __DIR__ . '/connexionPDO.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $idCours = $_POST['idCours'];

    $Con = connexionPDO();
    $SQL = "UPDATE cours SET Supprime = 1 WHERE idCours = :idCours";
    $req = $Con->prepare($SQL);
    $req->execute([':idCours' => $idCours]);

    echo json_encode(['success' => true]);
}
?>