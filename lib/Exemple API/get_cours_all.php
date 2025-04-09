<?php
require_once __DIR__ . '/connexionPDO.php';
// Ajouter les en-têtes CORS pour autoriser les requêtes depuis Flutter Web
header('Access-Control-Allow-Origin: *'); // Autorise toutes les origines (à ajuster en production)
header('Access-Control-Allow-Methods: GET'); // Autorise uniquement GET
header('Access-Control-Allow-Headers: Content-Type'); // Autorise certains en-têtes
header('Content-Type: application/json'); // Indique que la réponse est en JSON

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $pdo = connexionPDO();

        // Requête pour récupérer tous les cours non supprimés
        $stmt = $pdo->prepare("SELECT idCours, Libcours, jour, HD, HF, RefGalop
                               FROM cours
                               WHERE Supprime = 0");
        $stmt->execute();
        $cours = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['success' => true, 'cours' => $cours]);
    } catch (Exception $e) {
        error_log("Erreur : " . $e->getMessage());
        echo json_encode(['success' => false, 'message' => 'Erreur : ' . $e->getMessage()]);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Méthode de requête non autorisée']);
}
?>