$CSVFile = "C:\Scripts\create-users\create.csv"
$CSVData = Import-CSV -Path $CSVFile -Delimiter ";" -Encoding UTF8

# Generate password with special characters and length = 12
function Generate-RandomPassword {
    param (
        [int]$length
    )

    $upperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $lowerCaseChars = 'abcdefghijklmnopqrstuvwxyz'
    $numericChars = '0123456789'
    $specialChars = '!,:§&-*=+<>'

    $password = ''

    # password requirements
    $password += $upperCaseChars | Get-Random -Count 1
    $password += $lowerCaseChars | Get-Random -Count 1
    $password += $numericChars | Get-Random -Count 1
    $password += $specialChars | Get-Random -Count 1

    # Generate other characters at the end of the password
    $remainingLength = $length - 4
    $validChars = $upperCaseChars + $lowerCaseChars + $numericChars + $specialChars
    $random = 1..$remainingLength | ForEach-Object { Get-Random -Maximum $validChars.Length }
    $password += -join ($random | ForEach-Object { $validChars[$_] })

    # Mix characters
    $password = -join ($password.ToCharArray() | Get-Random -Count $password.Length)

    # Make sur of the length
    $password = $password.Substring(0, $length)

    return $password
}

Foreach($Utilisateur in $CSVData){

    $UtilisateurPrenom = $Utilisateur.Prenom
    $UtilisateurNom = $Utilisateur.Nom
    $UtilisateurLogin = ($UtilisateurPrenom).Substring(0,1) + "." + $UtilisateurNom
    $UtilisateurEmail = "$UtilisateurLogin@mycompany.local"
    $UtilisateurFonction = $Utilisateur.Fonction

    # User exist in the AD ?
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
                    # login
                    -UserPrincipalName "$UtilisateurLogin@mycompany.local" `
                    -EmailAddress $UtilisateurEmail `
                    -Title $UtilisateurFonction `
                    # Path to the OU
                    -Path "OU=utilisateurs,DC=mycompany,DC=local" `
                    -AccountPassword (ConvertTo-SecureString $UtilisateurMotDePasse -AsPlainText -Force) `
                    -ChangePasswordAtLogon $true `
                    -Enabled $true

        Write-Output "Création de l'utilisateur : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)"
    }
}

# Export CSV
$CSVData | Export-Csv -Path $CSVFile -Delimiter ";" -Encoding UTF8 -NoTypeInformation