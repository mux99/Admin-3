# Chemin du fichier CSV
$CSVFile = "C:\Scripts\unlock-users\unlock.csv"

# Importer les données du fichier CSV
$CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

# Parcourir chaque utilisateur du CSV
foreach ($Utilisateur in $CSVData) {
    $UtilisateurLogin = $Utilisateur.NomUtilisateur

    # Obtenir l'utilisateur et son état de verrouillage
    $utilisateur = Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin} -Properties BadPwdCount,LockedOut

    # Vérifier si le compte est verrouillé
    if ($utilisateur.LockedOut -and $utilisateur.BadPwdCount -ge 3) {
        # Afficher un message
        Write-Output "Le compte utilisateur $UtilisateurLogin est actuellement verrouillé."

        # Débloquer le compte
        Unlock-ADAccount -Identity $UtilisateurLogin

        Write-Output "Le compte utilisateur $UtilisateurLogin a été débloqué."
    } else {
        Write-Output "Le compte utilisateur $UtilisateurLogin n'est pas verrouillé ou n'a pas dépassé le nombre d'échecs autorisé."
    }
}