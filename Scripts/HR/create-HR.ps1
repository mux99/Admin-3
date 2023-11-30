$CSVFile = "\\Net01-server\hr\creation.csv"
$CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

# Fonction pour générer un mot de passe excluant certains caractères spéciaux
function Generate-RandomPassword {
    param (
        [int]$length
    )

    $upperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $lowerCaseChars = 'abcdefghijklmnopqrstuvwxyz'
    $numericChars = '0123456789'
    $specialChars = '!,:§&-*=+<>'

    $password = ''

    # Ajouter au moins une majuscule, une minuscule, un chiffre et un caractère spécial
    $password += $upperCaseChars | Get-Random -Count 1
    $password += $lowerCaseChars | Get-Random -Count 1
    $password += $numericChars | Get-Random -Count 1
    $password += $specialChars | Get-Random -Count 1

    # Générer le reste du mot de passe
    $remainingLength = $length - 4
    $validChars = $upperCaseChars + $lowerCaseChars + $numericChars + $specialChars
    $random = 1..$remainingLength | ForEach-Object { Get-Random -Maximum $validChars.Length }
    $password += -join ($random | ForEach-Object { $validChars[$_] })

    # Mélanger le mot de passe pour plus de sécurité
    $password = -join ($password.ToCharArray() | Get-Random -Count $password.Length)

    # Assurer que la longueur est exacte
    $password = $password.Substring(0, $length)

    return $password
}

Foreach($Utilisateur in $CSVData){

    $UtilisateurPrenom = $Utilisateur.Prenom
    $UtilisateurNom = $Utilisateur.Nom
    $UtilisateurLogin = ($UtilisateurPrenom).Substring(0,1) + "." + $UtilisateurNom
    $UtilisateurEmail = "$UtilisateurLogin@mycompany.local"
    $UtilisateurFonction = $Utilisateur.Fonction

    # Vérifier la présence de l'utilisateur dans l'AD
    if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin}) {
        Write-Warning "L'identifiant $UtilisateurLogin existe déjà dans l'AD"
    }
    else {
        $UtilisateurMotDePasse = Generate-RandomPassword -Length 12
        $Utilisateur | Add-Member -MemberType NoteProperty -Name "MotDePasse" -Value $UtilisateurMotDePasse -Force

        New-ADUser -Name "$UtilisateurNom $UtilisateurPrenom" `
                    -DisplayName "$UtilisateurNom $UtilisateurPrenom" `
                    -GivenName $UtilisateurPrenom `
                    -Surname $UtilisateurNom `
                    -SamAccountName $UtilisateurLogin `
                    -UserPrincipalName "$UtilisateurLogin@mycompany.local" `
                    -EmailAddress $UtilisateurEmail `
                    -Title $UtilisateurFonction `
                    -Path "OU=utilisateurs,DC=mycompany,DC=local" `
                    -AccountPassword (ConvertTo-SecureString $UtilisateurMotDePasse -AsPlainText -Force) `
                    -ChangePasswordAtLogon $true `
                    -Enabled $true

        Write-Output "Création de l'utilisateur : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)"
    }
}

# Exporter le CSV mis à jour
$CSVData | Export-Csv -Path $CSVFile -Delimiter ";" -Encoding UTF8 -NoTypeInformation