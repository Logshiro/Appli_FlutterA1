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

    error_log("Données reçues dans unsubscribe_course.php : cavalier_id=$cavalier_id, cours_id=$cours_id");

    if (!$cavalier_id || !$cours_id) {
        echo json_encode(['success' => false, 'message' => 'Données manquantes']);
        exit;
    }

    // Vérifie si le cavalier est inscrit au cours (table inscrit, Supprime = 0)
    $sql_check_inscrit = "SELECT * FROM inscrit WHERE RefCavalier = :cavalier_id AND RefCours = :cours_id AND Supprime = 0";
    $stmt_check_inscrit = $pdo->prepare($sql_check_inscrit);
    $stmt_check_inscrit->execute([
        ':cavalier_id' => $cavalier_id,
        ':cours_id' => $cours_id,
    ]);
    $inscrit = $stmt_check_inscrit->fetch(PDO::FETCH_ASSOC);

    if (!$inscrit) {
        // Le cavalier n'est pas inscrit
        echo json_encode(['success' => false, 'message' => 'Vous n\'êtes pas inscrit à ce cours']);
        exit;
    }

    // Marque l'inscription comme supprimée dans la table inscrit (Supprime = 1)
    $sql_update_inscrit = "UPDATE inscrit SET Supprime = 1 WHERE RefCavalier = :cavalier_id AND RefCours = :cours_id";
    $stmt_update_inscrit = $pdo->prepare($sql_update_inscrit);
    $stmt_update_inscrit->execute([
        ':cavalier_id' => $cavalier_id,
        ':cours_id' => $cours_id,
    ]);

    // Met à jour toutes les entrées dans participe pour ce cours et ce cavalier avec present = 0
    $sql_update_participe = "UPDATE participe 
                             SET present = 0 
                             WHERE idCoursCours = :cours_id 
                             AND RefCavalier = :cavalier_id";
    $stmt_update_participe = $pdo->prepare($sql_update_participe);
    $stmt_update_participe->execute([
        ':cours_id' => $cours_id,
        ':cavalier_id' => $cavalier_id,
    ]);

    error_log("Désinscription réussie pour cavalier_id=$cavalier_id, cours_id=$cours_id");
    echo json_encode(['success' => true, 'message' => 'Désinscription du cours réussie, vous ne participez plus à aucune séance']);
} catch (Exception $e) {
    error_log("Erreur : " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Erreur : ' . $e->getMessage()]);
}
?>