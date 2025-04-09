<?php
require_once __DIR__ . '/connexionPDO.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        if (isset($_POST['cavalier_id'])) {
        $cavalier_id = isset($_POST['cavalier_id']) ? $_POST['cavalier_id'] : null;

        if (!$cavalier_id) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'ID du cavalier manquant']);
            exit;
        }

        try {
            $pdo = connexionPDO();
            $sql = "SELECT c.* FROM cours c
                    JOIN inscrit i ON c.idCours = i.RefCours
                    WHERE i.RefCavalier = ? and i.Supprime = 0";
            $stmt = $pdo->prepare($sql);
            $stmt->execute([$cavalier_id]);
            $courses = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($courses) > 0) {
                echo json_encode(['success' => true, 'courses' => $courses]);
            } else {
                echo json_encode(['success' => true, 'courses' => [], 'message' => 'Aucun cours trouvé']);
            }
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Erreur SQL: ' . $e->getMessage()]);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Données manquantes']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Méthode de requête non autorisée']);
}

exit;
?>