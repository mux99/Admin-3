# Path to CSV
$CSVFile = "C:\Scripts\enable-users\enable.csv"

# Importe data from CSV
$CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

foreach ($Utilisateur in $CSVData) {
    $UtilisateurLogin = $Utilisateur.Login

    # If user exist
    if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin}) {
        # Enable account
        Enable-ADAccount -Identity $UtilisateurLogin
        Write-Output "Activation de l'utilisateur : $UtilisateurLogin"
    } else {
        Write-Warning "L'identifiant $UtilisateurLogin n'existe pas dans l'AD."
    }
}