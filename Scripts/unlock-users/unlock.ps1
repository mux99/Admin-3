# Path to CSV
$CSVFile = "C:\Scripts\unlock-users\unlock.csv"

# Import CSV data
$CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

foreach ($Utilisateur in $CSVData) {
    $UtilisateurLogin = $Utilisateur.NomUtilisateur

    # Get user
    $utilisateur = Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin} -Properties BadPwdCount,LockedOut

    # Verify account is locked
    if ($utilisateur.LockedOut -and $utilisateur.BadPwdCount -ge 3) {
        Write-Output "Le compte utilisateur $UtilisateurLogin est actuellement verrouillé."

        # unlock account
        Unlock-ADAccount -Identity $UtilisateurLogin
        Write-Output "Le compte utilisateur $UtilisateurLogin a été débloqué."
    } else {
        Write-Output "Le compte utilisateur $UtilisateurLogin n'est pas verrouillé ou n'a pas dépassé le nombre d'échecs autorisé."
    }
}