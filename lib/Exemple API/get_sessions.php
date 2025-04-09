<?php
require_once __DIR__ . '/connexionPDO.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['cours_id'])) {
        $cours_id = $_POST['cours_id'];

        try {
            $pdo = connexionPDO();

            // Récupère les séances du cours
            $stmt = $pdo->prepare("
                SELECT c.idCourSeance, c.DateCours
                FROM calendrier c
                WHERE c.idCoursCours = :cours_id
            ");
            $stmt->execute([':cours_id' => $cours_id]);
            $sessions = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if ($sessions) {
                echo json_encode(['success' => true, 'sessions' => $sessions]);
            } else {
                echo json_encode(['success' => false, 'message' => 'Aucune séance trouvée']);
            }
        } catch (Exception $e) {
            error_log("Erreur : " . $e->getMessage());
            echo json_encode(['success' => false, 'message' => 'Erreur : ' . $e->getMessage()]);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Données manquantes']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Méthode de requête non autorisée']);
}
?>