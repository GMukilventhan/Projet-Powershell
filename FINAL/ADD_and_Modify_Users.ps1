$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory
Import-Module $PSScriptRoot/Module.psm1

$global:filelogs = "Logs/Modif.json"

# TODO mettre de truc en fonction

# TODO mettre des try viré tous les silence continue FAIT 
# TODO FONTION MDP EXPLIQUER OU A REFAIRE FAIT 
# TODO METTRE A JOUR LE CSV !!! FAIT 

# TODO FAIRE LES LOGS PLUS TARD
# TODO EXPORT CSV END SCRIPT PLUS TARD 

# TODO RELIRE LE SCRIPT REFAIRE L'ALGO THEO

# Importe les données du fichier CSV
$CSVpath = "CSV/user.csv"
$CSVdata = Import-CSV -Path $CSVpath -Delimiter ";" -Encoding Default

# Pour chaque ligne du fichier CSV
foreach ($User in $CSVdata) {

    $UserFirstname = $User.Firstname
    $UserLastname = $User.Lastname.ToUpper()
    $UserDisplay = $UserFirstname + " " + $UserLastname.ToUpper()
    $UserFirstnameLastname = $UserFirstname.ToLower() + "." + $UserLastname.ToLower()
    $password = New-RandomSecurePassword -Length 12 -Characters 'A-Za-z0-9!@#$%^&*_-'
    $UPN = $UserFirstnameLastname + "@biodevops.local"
    $UserEmail = $UserFirstnameLastname + "@biodevops.eu"
    $UserTitle = "Etudiant"
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
    $uniqueRandomNumbers = @()
    $UserActivation = $User.Activation

    #FIXME count
    for ($i = 0; $i -lt 10; $i++) {
        $uniqueRandomNumbers += Get-Random -Minimum 0 -Maximum 9
    }
  
    $UniqueId = "U" + $UserAnnee + (-join $uniqueRandomNumbers)

    # Vérifie si le groupe de sécurité et distribution  existe déjà
    # tester
    #FIXME: a refaire  FAIT mais check si ca marche

    try {
        $GroupSecurityExists = Get-ADGroup -Filter {Name -eq $GroupNameSecurity}
    } catch {
        $GroupSecurityExists = $false
    }

    if (!$GroupSecurityExists) {
        New-ADGroup -Name $GroupNameSecurity -Path $GroupPath -GroupScope Global -GroupCategory Security
        Write-Output "Création du groupe de sécurité : $GroupNameSecurity !"
    }

    try {
        $GroupDistributionExists = Get-ADGroup -Filter {Name -eq $GroupNameDistribution}
    } catch {
        $GroupDistributionExists = $false
    }

    if (!$GroupDistributionExists) {
        New-ADGroup -Name $GroupNameDistribution -Path $GroupPath -GroupScope Global -GroupCategory Distribution -OtherAttributes @{'mail'= $GroupDistributionEmail}
        Write-Output "Création du groupe de distribution : $GroupNameDistribution !"
    }

    $UserExists = Get-ADUser -Filter {SamAccountName -eq $UniqueId}

    # Si l'utilisateur existe déjà
    #
    # faire attention de fouuuu malade
    #
    #

    if ($UserExists) {
        # Génère un nouveau nom d'utilisateur en ajoutant un numéro au nom de l'utilisateur
        $i = 1
        while ($UserExists) {
            $UserFirstnameLastname = $UserFirstnameLastname + $i
            $UPN = $UserFirstnameLastname + "@biodevops.local"
            $UserEmail = $UserFirstnameLastname + "@biodevops.eu"
            $UserExists = Get-ADUser -Filter {SamAccountName -eq $UniqueId} SilentlyContinue
            $i++
            $UserDisplay = $UserDisplay + $i
        }
    }else {
        New-ADUser `
            -Name $UserDisplay `
            -GivenName $UserFirstname `
            -Surname $UserLastname `
            -DisplayName $UserDisplay `
            -SamAccountName $UniqueId `
            -UserPrincipalName $UPN `
            -EmailAddress $UserEmail `
            -Title $UserTitle `
            -Department $UserClasse `
            -Company $UserCpny `
            -Path $UserPath `
            -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) `
            -ChangePasswordAtLogon $True `
            -Enabled $UserActivation

        Write-Output "Création de l'utilisateur : $UserDisplay !"
        Add-ADGroupMember -Identity $GroupNameSecurity -Members $UserFirstnameLastname
        Add-ADGroupMember -Identity $GroupNameDistribution -Members $GroupNameSecurity
    }

    $users = @()
    $users += New-Object -TypeName PSObject -Property @{
        "Username" = $UserFirstnameLastname
        "Password" = $password
    }
    $users | Export-Csv -Path "C:\password.csv" -Append -NoType
}
