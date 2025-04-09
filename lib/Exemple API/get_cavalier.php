<?php
require_once __DIR__ . '/connexionPDO.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if (!isset($_GET['id']) || empty($_GET['id'])) {
    http_response_code(400);
    echo json_encode(["error" => "ID cavalier requis"]);
    exit;
}

$idC = $_GET['id'];

try {
    $pdo = connexionPDO();
    $stmt = $pdo->prepare("SELECT * FROM cavalier WHERE idCavalier = :id AND Supprime = 0");
    $stmt->bindParam(':id', $idC, PDO::PARAM_INT);
    $stmt->execute();
    $cavalier = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($cavalier) {
        echo json_encode($cavalier);
    } else {
        http_response_code(404);
        echo json_encode(["error" => "Cavalier non trouvé"]);
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Erreur SQL: " . $e->getMessage()]);
    exit;
}
?>