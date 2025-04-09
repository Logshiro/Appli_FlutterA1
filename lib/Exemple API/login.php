<?php
require_once __DIR__ . '/connexionPDO.php';

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

require_once __DIR__ . '/connexionPDO.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $mail = $_POST['mail'] ?? '';
    $password = $_POST['password'] ?? '';

    error_log("Mail reçu : " . $mail);

    if (!empty($mail) && !empty($password)) {
        try {
            $pdo = connexionPDO();
            $stmt = $pdo->prepare("SELECT c.idCavalier, u.mail, u.passwordA, u.RefRole, r.LibRole
                                   FROM utilisateurs u
                                   INNER JOIN role r ON u.RefRole = r.idU
                                   INNER JOIN cavalier c ON u.mail = c.MailResponsable
                                   WHERE u.mail = :mail");
            $stmt->bindParam(':mail', $mail, PDO::PARAM_STR);
            $stmt->execute();

            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($user && password_verify($password, $user['passwordA'])) {
                echo json_encode(['success' => true, 'role' => $user['LibRole'], 'mail' => $user['mail'], 'id' => $user['idCavalier']]);
            } else {
                echo json_encode(['success' => false, 'message' => 'Identifiants incorrects']);
            }
        } catch (Exception $e) {
            error_log("Erreur : " . $e->getMessage());
            echo json_encode(['success' => false, 'message' => 'Erreur : ' . $e->getMessage()]);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Veuillez remplir tous les champs']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Méthode de requête non autorisée']);
}
?>
