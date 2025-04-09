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
    $data = json_decode(file_get_contents('php://input'), true);
    $cavalier_id = isset($data['cavalier_id']) ? $data['cavalier_id'] : null;
    $session_id = isset($data['session_id']) ? $data['session_id'] : null;
    $course_id = isset($data['course_id']) ? $data['course_id'] : null;

    // Log des données reçues pour débogage
    error_log("Données reçues dans participate_session.php : " . json_encode($data));

    if (!$cavalier_id || !$session_id || !$course_id) {
        error_log("Données manquantes : cavalier_id=$cavalier_id, session_id=$session_id, course_id=$course_id");
        echo json_encode(['success' => false, 'message' => 'Données manquantes']);
        exit;
    }

    // Vérifie si une entrée existe déjà pour cette séance et ce cavalier
    $sql_check = "SELECT * FROM participe WHERE idCourSeance = :session_id AND idCoursCours = :course_id AND RefCavalier = :cavalier_id";
    $stmt_check = $pdo->prepare($sql_check);
    $stmt_check->execute([
        ':session_id' => $session_id,
        ':course_id' => $course_id,
        ':cavalier_id' => $cavalier_id,
    ]);
    $result = $stmt_check->fetchAll(PDO::FETCH_ASSOC);

    if (count($result) > 0) {
        // Une entrée existe, met à jour le champ present à 1
        $sql_update = "UPDATE participe SET present = 1 WHERE idCourSeance = :session_id AND idCoursCours = :course_id AND RefCavalier = :cavalier_id";
        $stmt_update = $pdo->prepare($sql_update);
        $stmt_update->execute([
            ':session_id' => $session_id,
            ':course_id' => $course_id,
            ':cavalier_id' => $cavalier_id,
        ]);

        error_log("Inscription réussie pour cavalier_id=$cavalier_id, session_id=$session_id, course_id=$course_id");
        echo json_encode(['success' => true, 'message' => 'Inscription à la séance réussie']);
    } else {
        // Aucune entrée n'existe, insère une nouvelle entrée avec present = 1
        $sql_insert = "INSERT INTO participe (idCourSeance, idCoursCours, RefCavalier, present, Supprime) VALUES (:session_id, :course_id, :cavalier_id, 1, 0)";
        $stmt_insert = $pdo->prepare($sql_insert);
        $stmt_insert->execute([
            ':session_id' => $session_id,
            ':course_id' => $course_id,
            ':cavalier_id' => $cavalier_id,
        ]);

        error_log("Nouvelle inscription réussie pour cavalier_id=$cavalier_id, session_id=$session_id, course_id=$course_id");
        echo json_encode(['success' => true, 'message' => 'Inscription à la séance réussie']);
    }
} catch (Exception $e) {
    error_log("Erreur : " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Erreur : ' . $e->getMessage()]);
}
?>