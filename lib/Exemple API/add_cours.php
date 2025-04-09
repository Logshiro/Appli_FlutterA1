<?php
require_once __DIR__ . '/connexionPDO.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $libCours = $_POST['Libcours'];
    $jour = $_POST['jour'];
    $horaireD = $_POST['HD'];
    $horaireF = $_POST['HF'];
    $idGalop = $_POST['RefGalop'];

    $Con = connexionPDO();

    // Vérification si le cours existe déjà
    $SQL_CHECK = "SELECT COUNT(*) FROM cours WHERE Libcours = :Libcours AND jour = :jour AND HD = :HD AND HF = :HF AND RefGalop = :idGalop";
    $reqCheck = $Con->prepare($SQL_CHECK);
    
    $dataCheck = [
        ':Libcours' => $libCours,
        ':jour' => $jour,
        ':HD' => $horaireD,
        ':HF' => $horaireF,
        ':idGalop' => $idGalop
    ];

    $reqCheck->execute($dataCheck);
    $existingCourseCount = $reqCheck->fetchColumn();

    if ($existingCourseCount > 0) {
        echo json_encode(['success' => false, 'error' => 'Le cours existe déjà.']);
    } else {
        // Insertion si le cours n'existe pas
        $SQL_INSERT = "INSERT INTO cours (Libcours, jour, HD, HF, RefGalop) VALUES (:Libcours, :jour, :HD, :HF, :idGalop)";
        $reqInsert = $Con->prepare($SQL_INSERT);

        if ($reqInsert->execute($dataCheck)) {
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false, 'error' => 'Erreur lors de l\'insertion.']);
        }
    }
}
?>
