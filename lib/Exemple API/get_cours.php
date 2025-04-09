<?php
require_once __DIR__ . '/connexionPDO.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $mail = $_POST['mail'] ?? '';

    error_log("Mail reçu : " . $mail);

    if (!empty($mail)) {
        try {
            $pdo = connexionPDO();

            $stmt = $pdo->prepare("SELECT c.idCavalier
                                   FROM Cavalier c
                                   WHERE c.MailResponsable = :mail");
            $stmt->bindParam(':mail', $mail, PDO::PARAM_STR);
            $stmt->execute();
            $cavalier = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($cavalier) {
                $idCavalier = $cavalier['idCavalier'];

                $stmt = $pdo->prepare("SELECT c.idCours, c.Libcours, c.jour, c.HD, c.HF, c.RefGalop
                                      FROM cours c
                                      INNER JOIN Inscrit i ON c.idCours = i.RefCours
                                      WHERE i.RefCavalier = :idCavalier AND c.Supprime = 0");
                $stmt->bindParam(':idCavalier', $idCavalier, PDO::PARAM_INT);
                $stmt->execute();
                $cours = $stmt->fetchAll(PDO::FETCH_ASSOC);

                echo json_encode(['success' => true, 'cours' => $cours]);
            } else {
                echo json_encode(['success' => false, 'message' => 'Aucun cavalier trouvé avec cet email']);
            }
        } catch (Exception $e) {
            error_log("Erreur : " . $e->getMessage());
            echo json_encode(['success' => false, 'message' => 'Erreur : ' . $e->getMessage()]);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Veuillez fournir une adresse e-mail']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Méthode de requête non autorisée']);
}
?>
