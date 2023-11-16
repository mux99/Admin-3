# Path to CSV
$CSVFile = "C:\Scripts\modify users\modify.csv"

# Import data from CSV
$CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

foreach ($Utilisateur in $CSVData) {
    $UtilisateurLogin = $Utilisateur.NomUtilisateur
    $UtilisateurAD = Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin}

    # If user exists
    if ($UtilisateurAD) {
        Update differents values
        if ($Utilisateur.Description) {
            Set-ADUser -Identity $UtilisateurLogin -Description $Utilisateur.Description
            Write-Output "Description mise à jour pour $UtilisateurLogin"
        }
        if ($Utilisateur.Bureau) {
            Set-ADUser -Identity $UtilisateurLogin -Office $Utilisateur.Bureau
            Write-Output "Bureau mis à jour pour $UtilisateurLogin"
        }
        if ($Utilisateur.Telephone) {
            Set-ADUser -Identity $UtilisateurLogin -OfficePhone $Utilisateur.Telephone
            Write-Output "Numéro de téléphone mis à jour pour $UtilisateurLogin"
        }
        if ($Utilisateur.MotDePasse) {
            Set-ADAccountPassword -Identity $UtilisateurLogin -NewPassword (ConvertTo-SecureString -AsPlainText $Utilisateur.MotDePasse -Force) -Reset
            Write-Output "Mot de passe mis à jour pour $UtilisateurLogin"
        }
    } else {
        Write-Warning "L'utilisateur $UtilisateurLogin n'a pas été trouvé dans Active Directory."
    }
}