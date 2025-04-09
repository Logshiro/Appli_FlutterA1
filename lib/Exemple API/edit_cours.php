<?php

require_once __DIR__ . '/connexionPDO.php';
public function edit(){
    try {
        $Con = connexionPDO(); // Connexion PDO
        $SQL = "UPDATE cours 
                SET Libcours = :Libcours, 
                    jour = :jour,
                    HD = :HD,
                    HF = :HF,
                    RefGalop = :idGalop
                WHERE idCours = :idCours";

        $req = $Con->prepare($SQL);

        // Variables PHP -> SQL
        $data = [
            ":idCours" => $this->idcours,
            ":Libcours" => $this->libcours,
            ":jour" => $this->jourC,
            ":HD" => $this->horaireD, 
            ":HF" => $this->horaireF, 
            ":idGalop" => $this->idGalop
        ];

        // Exécution et vérification du succès
        if ($req->execute($data)) {
            echo json_encode([
                "success" => true,
                "message" => "Cours modifié avec succès."
            ]);
        } else {
            echo json_encode([
                "success" => false,
                "message" => "La modification du cours a échoué."
            ]);
        }
    } catch (PDOException $e) {
        echo json_encode([
            "success" => false,
            "message" => "Erreur SQL : " . $e->getMessage()
        ]);
    }
}
?>