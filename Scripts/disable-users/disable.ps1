# Path to CSV
$CSVFile = "C:\Scripts\disable-users\disable.csv"

# Import CSV data
$CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

foreach ($Utilisateur in $CSVData) {

    # Nom d'utilisateur
    $UtilisateurLogin = $Utilisateur.Login

    # Verify if user in AD
    if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin}) {
        # Disable account
        Disable-ADAccount -Identity $UtilisateurLogin

        Write-Output "Désactivation de l'utilisateur : $UtilisateurLogin"
    } else {
        Write-Warning "L'identifiant $UtilisateurLogin n'existe pas dans l'AD."
    }
}