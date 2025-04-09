<?php
require_once __DIR__ . '/connexionPDO.php';

// Ajouter les en-têtes CORS pour autoriser les requêtes depuis Flutter Web
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

try {
    $pdo = connexionPDO(); // Établit la connexion à la base de données via PDO

    // Récupère les données envoyées par l'application
    $cavalier_id = isset($_POST['cavalier_id']) ? $_POST['cavalier_id'] : null;
    $session_id = isset($_POST['session_id']) ? $_POST['session_id'] : null;
    $course_id = isset($_POST['course_id']) ? $_POST['course_id'] : null;

    // Log des données reçues pour débogage
    error_log("Données reçues dans check_participation.php : cavalier_id=$cavalier_id, session_id=$session_id, course_id=$course_id");

    if (!$cavalier_id || !$session_id || !$course_id) {
        echo json_encode(['success' => false, 'message' => 'Données manquantes']);
        exit;
    }

    // Vérifie l'état de participation
    $sql = "SELECT present FROM participe WHERE idCourSeance = :session_id AND idCoursCours = :course_id AND RefCavalier = :cavalier_id";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        ':session_id' => $session_id,
        ':course_id' => $course_id,
        ':cavalier_id' => $cavalier_id,
    ]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        $isParticipating = (bool)$result['present'];
        echo json_encode(['success' => true, 'isParticipating' => $isParticipating]);
    } else {
        // Si aucune entrée n'existe, on suppose que le cavalier participe par défaut
        echo json_encode(['success' => true, 'isParticipating' => true]);
    }
} catch (Exception $e) {
    error_log("Erreur : " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Erreur : ' . $e->getMessage()]);
}
?>