$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory
Import-Module $PSScriptRoot/Module.psm1

$global:filelogs = "Logs/Modif.json"


# TODO EXPORT CSV END SCRIPT PLUS TARD 


# Importe les données du fichier CSV
$CSVpath = "CSV/user.csv"
$CSVdata = Import-CSV -Path $CSVpath -Delimiter ";" -Encoding Default

# Pour chaque ligne du fichier CSV
foreach ($User in $CSVdata) {
    $UserUPN = $User.UPN
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

    $UserActivation = $User.Activation

    $uniqueRandomNumbers = -join (0..9| Get-Random -Count 10)
    $UniqueId = "U" + $UserAnnee + (-join $uniqueRandomNumbers)

    if ($UserUPN -eq "Null"){            
        $UserExists = Get-ADUser -Filter {SamAccountName -eq $UniqueId}
        $i = 1
        while ($UserExists) {
            $UserFirstnameLastname = $UserFirstnameLastname + $i
            $UPN = $UserFirstnameLastname + "@biodevops.local"
            $UserEmail = $UserFirstnameLastname + "@biodevops.eu"
            $UserExists = Get-ADUser -Filter {SamAccountName -eq $UniqueId}
            $i++
            $UserDisplay = $UserDisplay + $i
        }
        try {
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

            Write-Success -Message "création de l'utilisateur :" -Commentaire $UserDisplay
        }catch {
            Write-Warning -Message "création de l'utilisateur impossible:" -Commentaire $UserDisplay
        }


        try {
            Add-ADGroupMember -Identity $GroupNameSecurity -Members $UserFirstnameLastname
            Add-ADGroupMember -Identity $GroupNameDistribution -Members $GroupNameSecurity
        }catch {
            Write-Warning -Message "error" -Commentaire "error"
        }

    }else {
        $UserExists = Get-ADUser -Filter {SamAccountName -eq $UniqueId}
        if ($UserExists) {
            # get les info de l'ad
            # comparaison
            #
            # GET info AD
            # if infoAD pas= INFOCSV si oui #a modifier infoCSV > infoAD
        }else{
            echo "error"
        }
    }

    $users = @()
    $users += New-Object -TypeName PSObject -Property @{
        "Username" = $UserFirstnameLastname
        "Password" = $password
    }
    $users | Export-Csv -Path "C:\password.csv" -Append -NoType
}
