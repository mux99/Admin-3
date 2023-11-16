# Chemin du fichier CSV
$CSVFile = "C:\Scripts\modify users\modify.csv"

# Importer les données du fichier CSV
$CSVData = Import-CSV -Path $CSVFile -Delimiter "," -Encoding UTF8

# Parcourir chaque utilisateur du CSV
foreach ($Utilisateur in $CSVData) {
    $UtilisateurLogin = $Utilisateur.NomUtilisateur

    # Obtenir l'utilisateur
    $UtilisateurAD = Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin}

    # Vérifier si l'utilisateur existe
    if ($UtilisateurAD) {
        # Mettre à jour la description si une nouvelle valeur est spécifiée
        if ($Utilisateur.Description) {
            Set-ADUser -Identity $UtilisateurLogin -Description $Utilisateur.Description
            Write-Output "Description mise à jour pour $UtilisateurLogin"
        }

        # Mettre à jour le bureau si une nouvelle valeur est spécifiée
        if ($Utilisateur.Bureau) {
            Set-ADUser -Identity $UtilisateurLogin -Office $Utilisateur.Bureau
            Write-Output "Bureau mis à jour pour $UtilisateurLogin"
        }

        # Mettre à jour le numéro de téléphone si une nouvelle valeur est spécifiée
        if ($Utilisateur.Telephone) {
            Set-ADUser -Identity $UtilisateurLogin -OfficePhone $Utilisateur.Telephone
            Write-Output "Numéro de téléphone mis à jour pour $UtilisateurLogin"
        }

        # Mettre à jour le mot de passe si une nouvelle valeur est spécifiée
        if ($Utilisateur.MotDePasse) {
            Set-ADAccountPassword -Identity $UtilisateurLogin -NewPassword (ConvertTo-SecureString -AsPlainText $Utilisateur.MotDePasse -Force) -Reset
            Write-Output "Mot de passe mis à jour pour $UtilisateurLogin"
        }
    } else {
        Write-Warning "L'utilisateur $UtilisateurLogin n'a pas été trouvé dans Active Directory."
    }
}