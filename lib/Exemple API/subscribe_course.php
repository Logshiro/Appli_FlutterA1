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

    error_log("Données reçues dans subscribe_course.php : cavalier_id=$cavalier_id, cours_id=$cours_id");

    if (!$cavalier_id || !$cours_id) {
        echo json_encode(['success' => false, 'message' => 'Données manquantes']);
        exit;
    }

    // Vérifie si le cavalier est déjà inscrit au cours (table inscrit, Supprime = 0)
    $sql_check_inscrit = "SELECT * FROM inscrit WHERE RefCavalier = :cavalier_id AND RefCours = :cours_id AND Supprime = 0";
    $stmt_check_inscrit = $pdo->prepare($sql_check_inscrit);
    $stmt_check_inscrit->execute([
        ':cavalier_id' => $cavalier_id,
        ':cours_id' => $cours_id,
    ]);
    $inscrit = $stmt_check_inscrit->fetch(PDO::FETCH_ASSOC);

    if ($inscrit) {
        // Le cavalier est déjà inscrit
        echo json_encode(['success' => false, 'message' => 'Vous êtes déjà inscrit à ce cours']);
        exit;
    }

    // Ajoute ou met à jour l'inscription dans la table inscrit
    $sql_upsert_inscrit = "INSERT INTO inscrit (RefCavalier, RefCours, Supprime) 
                           VALUES (:cavalier_id, :cours_id, 0) 
                           ON DUPLICATE KEY UPDATE Supprime = 0";
    $stmt_upsert_inscrit = $pdo->prepare($sql_upsert_inscrit);
    $stmt_upsert_inscrit->execute([
        ':cavalier_id' => $cavalier_id,
        ':cours_id' => $cours_id,
    ]);

    // Récupère toutes les séances du cours depuis la table calendrier
    $sql_get_sessions = "SELECT idCourSeance FROM calendrier WHERE idCoursCours = :cours_id";
    $stmt_get_sessions = $pdo->prepare($sql_get_sessions);
    $stmt_get_sessions->execute([':cours_id' => $cours_id]);
    $sessions = $stmt_get_sessions->fetchAll(PDO::FETCH_ASSOC);

    if (empty($sessions)) {
        // Pas de séances pour ce cours, on peut quand même confirmer l'inscription
        echo json_encode(['success' => true, 'message' => 'Inscription au cours réussie, mais aucune séance disponible']);
        exit;
    }

    // Ajoute ou met à jour une entrée dans participe pour chaque séance avec present = 1
    $sql_upsert_participe = "INSERT INTO participe (idCourSeance, idCoursCours, RefCavalier, present, Supprime) 
                             VALUES (:session_id, :cours_id, :cavalier_id, 1, 0) 
                             ON DUPLICATE KEY UPDATE present = 1, Supprime = 0";
    $stmt_upsert_participe = $pdo->prepare($sql_upsert_participe);

    foreach ($sessions as $session) {
        $stmt_upsert_participe->execute([
            ':session_id' => $session['idCourSeance'],
            ':cours_id' => $cours_id,
            ':cavalier_id' => $cavalier_id,
        ]);
    }

    error_log("Inscription réussie pour cavalier_id=$cavalier_id, cours_id=$cours_id");
    echo json_encode(['success' => true, 'message' => 'Inscription au cours réussie, vous participez à toutes les séances']);
} catch (Exception $e) {
    error_log("Erreur : " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Erreur : ' . $e->getMessage()]);
}
?>