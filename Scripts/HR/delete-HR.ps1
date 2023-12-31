# Chemin vers le fichier CSV
$CSVFile = "\\Net01-server\hr\suppression.csv"

# Importer les données depuis le fichier CSV
$CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

# Boucle à travers chaque utilisateur dans le fichier CSV
foreach ($Utilisateur in $CSVData) {
    # Nom d'utilisateur
    $UtilisateurLogin = $Utilisateur.Login

    # Vérifier si l'utilisateur existe dans l'AD
    if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin}) {
        # Supprimer l'utilisateur de l'AD
        Remove-ADUser -Identity $UtilisateurLogin -Confirm:$false

        Write-Output "Suppression de l'utilisateur : $UtilisateurLogin"
    } else {
        Write-Warning "L'identifiant $UtilisateurLogin n'existe pas dans l'AD."
    }
}