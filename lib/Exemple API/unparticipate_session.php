<?php
require_once __DIR__ . '/connexionPDO.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

try {
    $pdo = connexionPDO();

    $data = json_decode(file_get_contents('php://input'), true);
    $cavalier_id = isset($data['cavalier_id']) ? $data['cavalier_id'] : null;
    $session_id = isset($data['session_id']) ? $data['session_id'] : null;
    $course_id = isset($data['course_id']) ? $data['course_id'] : null;

    error_log("Données reçues dans unparticipate_session.php : " . json_encode($data));

    if (!$cavalier_id || !$session_id || !$course_id) {
        error_log("Données manquantes : cavalier_id=$cavalier_id, session_id=$session_id, course_id=$course_id");
        echo json_encode(['success' => false, 'message' => 'Données manquantes']);
        exit;
    }

    $sql_check = "SELECT * FROM participe WHERE idCourSeance = :session_id AND idCoursCours = :course_id AND RefCavalier = :cavalier_id";
    $stmt_check = $pdo->prepare($sql_check);
    $stmt_check->execute([
        ':session_id' => $session_id,
        ':course_id' => $course_id,
        ':cavalier_id' => $cavalier_id,
    ]);
    $result = $stmt_check->fetchAll(PDO::FETCH_ASSOC);

    if (count($result) > 0) {
        // Une entrée existe, met à jour le champ present à 0
        $sql_update = "UPDATE participe SET present = 0 WHERE idCourSeance = :session_id AND idCoursCours = :course_id AND RefCavalier = :cavalier_id";
        $stmt_update = $pdo->prepare($sql_update);
        $stmt_update->execute([
            ':session_id' => $session_id,
            ':course_id' => $course_id,
            ':cavalier_id' => $cavalier_id,
        ]);

        error_log("Désinscription réussie pour cavalier_id=$cavalier_id, session_id=$session_id, course_id=$course_id");
        echo json_encode(['success' => true, 'message' => 'Désinscription de la séance réussie']);
    } else {
        // Aucune entrée n'existe, insère une nouvelle entrée avec present = 0
        $sql_insert = "INSERT INTO participe (idCourSeance, idCoursCours, RefCavalier, present, Supprime) VALUES (:session_id, :course_id, :cavalier_id, 0, 0)";
        $stmt_insert = $pdo->prepare($sql_insert);
        $stmt_insert->execute([
            ':session_id' => $session_id,
            ':course_id' => $course_id,
            ':cavalier_id' => $cavalier_id,
        ]);

        error_log("Nouvelle désinscription insérée pour cavalier_id=$cavalier_id, session_id=$session_id, course_id=$course_id");
        echo json_encode(['success' => true, 'message' => 'Désinscription de la séance réussie']);
    }
} catch (Exception $e) {
    error_log("Erreur : " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Erreur : ' . $e->getMessage()]);
}
?>