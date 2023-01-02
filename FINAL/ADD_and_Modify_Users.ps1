$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory
Import-Module $PSScriptRoot/Module.psm1

$global:filelogs = "Logs/Modif.json"



# Importe les données du fichier CSV
$CSVpath = "CSV/user.csv"
$CSVdata = Import-CSV -Path $CSVpath -Delimiter ";" -Encoding Default

# Pour chaque ligne du fichier CSV
foreach ($User in $CSVdata) {

    $UserFirstname = $User.Firstname
    $UserLastname = $User.Lastname.ToUpper()
    $UserDisplay = $UserFirstname + " " + $UserLastname.ToUpper()
    $UserLogon = $UserFirstname.ToLower() + "." + $UserLastname.ToLower()
    $password = -join (65..90 + 97..122 + 48..57 + 33..47 | Get-Random -Count 8 | %{[char]$_})
    $UPN = $UserLogon + "@biodevops.local"
    $UserEmail = $UserLogon + "@biodevops.eu"
    $UserTitle = $User.Title
    $UserCpny = $User.Company
    $UserAnnee = $User.Annee
    $UserAnneeEtude = $User.AnneeEtude
    $UserFiliere = $User.Filiere
    $UserPromotion = $User.Promotion
    $UserClasse = $UserAnnee + "_" + $UserPromotion
    $UserPath = "OU=$UserClasse,OU=$UserFiliere,OU=$UserAnneeEtude,OU=$UserAnnee,OU=ETUDIANTS,OU=BIODEVOPS,DC=mk,DC=lan"
    $GroupNameSecurity =  "Grp_Securite_" + $UserAnnee + "_" + $UserPromotion
    $GroupNameDistribution = "Grp_Distribution_" + $UserAnnee + "_" + $UserPromotion
    $GroupDistributionEmail = $UserPromotion + "." + $UserAnnee + "@biodevops.eu"
    $GroupPath = "OU=$UserClasse,OU=$UserFiliere,OU=$UserAnneeEtude,OU=$UserAnnee,OU=ETUDIANTS,OU=BIODEVOPS,DC=mk,DC=lan"
    $currentYear = (Get-Date).Year
    $uniqueRandomNumbers = @()

    for ($i = 0; $i -lt 10; $i++) {
        $uniqueRandomNumbers += Get-Random -Minimum 0 -Maximum 9
    }

    $uniqueId = "U" + $currentYear + (-join $uniqueRandomNumbers)

    # Vérifie si le groupe de sécurité et distribution  existe déjà
    # tester
    #FIXME: a refaire 
    $GroupExists = Get-ADGroup -Filter {Name -eq $GroupNameSecurity} -ErrorAction SilentlyContinue
    $GroupExists = Get-ADGroup -Filter {Name -eq $GroupNameDistribution} -ErrorAction SilentlyContinue

    # Si le groupe de sécurité n'existe pas, le créer
    if (!$GroupExists) {
        New-ADGroup -Name $GroupNameSecurity -Path $UserPath -GroupScope Global -GroupCategory Security
        Write-Output "Création du groupe de securite : $GroupNameSecurity !"
        New-ADGroup -Name $GroupNameDistribution -Path $UserPath -GroupScope Global -GroupCategory Distribution -OtherAttributes @{'mail'= $GroupDistributionEmail}
        Write-Output "Création du groupe de distribution : $GroupNameDistribution !"
    }

    $UserExists = Get-ADUser -Filter {SamAccountName -eq $uniqueId}

    # Si l'utilisateur existe déjà
    #
    # faire attention de fouuuu malade
    #
    #

    if ($UserExists) {
        # Génère un nouveau nom d'utilisateur en ajoutant un numéro au nom de l'utilisateur
        $i = 1
        while ($UserExists) {
            $UserLogon = $UserFirstname.ToLower() + "." + $UserLastname.ToLower() + $i
            $UPN = $UserLogon + "@biodevops.local"
            $UserEmail = $UserLogon + "@biodevops.eu"
            $UserExists = Get-ADUser -Filter {SamAccountName -eq $uniqueId} -ErrorAction SilentlyContinue
            $i++
            $UserDisplay = $UserFirstname + $UserLastname + $i
        }
    }else {
        New-ADUser `
            -Name $UserDisplay `
            -GivenName $UserFirstname `
            -Surname $UserLastname `
            -DisplayName $UserDisplay `
            -SamAccountName $UserLogon `
            -UserPrincipalName $UPN `
            -EmailAddress $UserEmail `
            -Title $UserTitle `
            -Department $UserClasse `
            -Company $UserCpny `
            -Path $UserPath `
            -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) `
            -ChangePasswordAtLogon $True `
            -Enabled $true

        Write-Output "Création de l'utilisateur : $UserDisplay !"
        Add-ADGroupMember -Identity $GroupNameSecurity -Members $UserLogon
        Add-ADGroupMember -Identity $GroupNameDistribution -Members $GroupNameSecurity
    }

    $users = @()
    $users += New-Object -TypeName PSObject -Property @{
        "Username" = $UserLogon
        "Password" = $password
    }
    $users | Export-Csv -Path "C:\password.csv" -Append -NoType
}
