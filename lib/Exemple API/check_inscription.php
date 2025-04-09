<?php
require_once __DIR__ . '/connexionPDO.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

try {
    $pdo = connexionPDO();

    // Récupère les données envoyées par l'application
    $cavalier_id = isset($_POST['cavalier_id']) ? $_POST['cavalier_id'] : null;
    $cours_id = isset($_POST['cours_id']) ? $_POST['cours_id'] : null;

    error_log("Données reçues dans check_inscription.php : cavalier_id=$cavalier_id, cours_id=$cours_id");

    if (!$cavalier_id || !$cours_id) {
        echo json_encode(['success' => false, 'message' => 'Données manquantes']);
        exit;
    }

    // Vérifie si le cavalier est inscrit au cours (table inscrit, Supprime = 0)
    $sql = "SELECT * FROM inscrit WHERE RefCavalier = :cavalier_id AND RefCours = :cours_id AND Supprime = 0";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ':cavalier_id' => $cavalier_id,
        ':cours_id' => $cours_id,
    ]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo json_encode(['success' => true, 'isRegistered' => true]);
    } else {
        echo json_encode(['success' => true, 'isRegistered' => false]);
    }
} catch (Exception $e) {
    error_log("Erreur : " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Erreur : ' . $e->getMessage()]);
}
?>