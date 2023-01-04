$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory
Import-Module $PSScriptRoot/Module.psm1

$global:filelogs = "Logs/Modif.json"


# TODO EXPORT CSV END SCRIPT PLUS TARD 


# Importe les donnÃƒÂ©es du fichier CSV
$CSVpath = "CSV/user.csv"
$CSVdata = Import-CSV -Path $CSVpath -Delimiter ";" -Encoding Default

# Pour chaque ligne du fichier CSV
foreach ($User in $CSVdata) {
    $UserSAM = $User.SAM
    $UserFirstname = $User.Firstname
    $UserLastname = $User.Lastname.ToUpper()
    $UserDisplay = $UserFirstname + " " + $UserLastname.ToUpper()
    $UserFirstnameLastname = $UserFirstname.ToLower() + "." + $UserLastname.ToLower()
    $password = -join (65..90 + 97..122 + 48..57 + 33..47 | Get-Random -Count 10 | %{[char]$_})
    $SAM = $UserFirstnameLastname + "@biodevops.local"
    $UserEmail = $UserFirstnameLastname + "@biodevops.eu"
    $UserTitle = "Etudiant"
    $UserCpny = $User.Company
    $UserAnnee = $User.Annee
    $UserAnneeEtude = $User.AnneeEtude
    $UserFiliere = $User.Filiere
    $UserPromotion = $User.Promotion
    $UserClasse = $UserAnnee + "_" + $UserPromotion
    $UserPath = "OU=$UserClasse,OU=$UserFiliere,OU=$UserAnneeEtude,OU=$UserAnnee,OU=ETUDIANTS,OU=BIODEVOPS,DC=labvmware,DC=local"
    $GrpSAMameSecurity =  "Grp_Securite_" + $UserAnnee + "_" + $UserPromotion
    $GrpSAMameDistribution = "Grp_Distribution_" + $UserAnnee + "_" + $UserPromotion
    $GroupDistributionEmail = $UserPromotion + "." + $UserAnnee + "@biodevops.eu"
    $GroupPath = "OU=$UserClasse,OU=$UserFiliere,OU=$UserAnneeEtude,OU=$UserAnnee,OU=ETUDIANTS,OU=BIODEVOPS,DC=labvmware,DC=local"

    $UserActivation = $User.Activation
    if ($UserActivation -eq "true"){
        $UserActivation = $True
    }elseif($UserActivation -eq "false"){
        $UserActivation = $False
    }

    $UserDelegue = $User.Delegue
    if ($UserDelegue -eq "true"){
        $UserDelegue = $True
    }elseif($UserrDelegue -eq "false"){
        $UserrDelegue = $False
    }


    $uniqueRandomNumbers = -join (0..9| Get-Random -Count 10)
    $UniqueId = "U" + $UserAnnee + (-join $uniqueRandomNumbers)

    
    if ($UserSAM -eq "Null"){            
        $i = 1
        $testuser = test-userexists -Identity $UserDisplay
        $OriginalUserFirstnameLastname = $UserFirstnameLastname
        $OriginalUserDisplay = $UserDisplay
  
        while ($testuser -eq $True) {
   
            $UserFirstnameLastname = $OriginalUserFirstnameLastname + $i
            $SAM = $UserFirstnameLastname + "@biodevops.local"
            $UserEmail = $UserFirstnameLastname + "@biodevops.eu"
            
            $UserDisplay = $OriginalUserDisplay + $i
            $testuser = test-userexists -Identity $UserDisplay
            $i++
        }
   
        try {
            New-ADUser `
            -Name $UserDisplay `
            -GivenName $UserFirstname `
            -Surname $UserLastname `
            -DisplayName $UserDisplay `
            -SamAccountName $UniqueId `
            -UserPrincipalName $SAM `
            -EmailAddress $UserEmail `
            -Title $UserTitle `
            -Department $UserClasse `
            -Company $UserCpny `
            -Path $UserPath `
            -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) `
            -ChangePasswordAtLogon $True `
            -Enabled $UserActivation

            Write-Success -Message "crÃƒÂ©ation de l'utilisateur :" -Commentaire $UserDisplay
            $users = @()
            $users += New-Object -TypeName PSObject -Property @{
            "Username" = $UserFirstnameLastname
            "Password" = $password
            }
            $users | Export-Csv -Path "C:\password.csv" -Append -NoType
        }catch {
            $_
            Write-Warning -Message "crÃƒÂ©ation de l'utilisateur impossible:" -Commentaire $UserDisplay
        }


        try {
            Add-ADPrincipalGroupMembership -Identity $uniqueId -MemberOf $GrpSAMameSecurity

        }catch {
           Write-Warning -Message "error" -Commentaire "error"
        }

    }else {
        # TODO: Test UserExist
        $UserExists = Get-ADUser -Filter {SamAccountName -eq $UniqueId}
        if ($UserExists) {
            $InfoADFirstname = $user.givenName
            $InfoADLastname = $User.sn
            #$InfoADTitle = $user.Title
            $InfoADUserActivation = $user.Enabled
            $InfoADUserDelegue = $user.Title 

            if($UserDelegue -eq $True){
                $DelegueMemberOf = Get-ADPrincipalGroupMembership $UniqueId | Where-Object {$_.name -like "Grp_Securite_*"}
                # R�cup�rer le nom de l'utilisateur et son SAMaccountName
                $AllMembersGroup = Get-ADGroupMember -Identity $DelegueMemberOf.Name
                foreach ($MemberGroup in $AllMembersGroup) {
                    If($MemberGroup.SamAccountName -ne $UserSAM){
                        # Ajouter le le nom du d�l�gu� en tant que manager pour les autres membres de son groupe
                        Set-ADUser -Identity $MemberGroup -Manager $UserSAM
                    }Else{
                        # Changer le champs Title actuellement Etudiant par Delegue
                        Set-ADUser -Identity $UserSam -Title "Delegue"
                    }
                  
                }

            }
            

            if ($DelegueAD -ne $DelegueCSV ) {
                try {
                    Set-ADUser -Identity $UniqueId -Title $DelegueCSV
                    Write-Success -Message "Modification du statut de l'utilisateur :" -Commentaire $UserDisplay
                }catch {
                    $_
                    Write-Warning -Message "Modification du statut de l'utilisateur impossible:" -Commentaire $UserDisplay
                }
            }

            if ($InfoADFirstname -ne $UserFirstname) {
                try {
                    Set-ADUser -Identity $UniqueId -GivenName $UserFirstname
                    Write-Success -Message "Modification du prÃƒÂ©nom de l'utilisateur :" -Commentaire $UserDisplay
                }catch {
                    $_
                    Write-Warning -Message "Modification du prÃƒÂ©nom de l'utilisateur impossible:" -Commentaire $UserDisplay
                }
            }
            if ($InfoADLastname -ne $UserLastname) {
                try {
                    Set-ADUser -Identity $UniqueId -Surname $UserLastname
                    Write-Success -Message "Modification du nom de l'utilisateur :" -Commentaire $UserDisplay
                }catch {
                    $_
                    Write-Warning -Message "Modification du nom de l'utilisateur impossible:" -Commentaire $UserDisplay
                }
            }
            if ($InfoADUserActivation -ne $UserActivation) {
                try {
                    Set-ADUser -Identity $UniqueId -Enabled $UserActivation
                    Write-Success -Message "Modification de l'activation de l'utilisateur :" -Commentaire $UserDisplay
                }catch {
                    $_
                    Write-Warning -Message "Modification de l'activation de l'utilisateur impossible:" -Commentaire $UserDisplay
                }
            }
        }else{
            echo "error"
        }
    }
    #export tous les champs generer dans un fichier csv
    $expusers = @()
    $expusers += New-Object -TypeName PSObject -Property @{ 
    "UniqueId" = $UniqueId  
    "Firstname" = $UserFirstname
    "Lastname" = $UserLastname
    "Company"= $UserCpny
    "Annee" = $UserAnnee
    "AnneeEtude" = $UserAnneeEtude
    "Filiere" = $UserFiliere
    "Promotion" = $UserPromotion
    "Activation" = $UserActivation
    "Delegue" = $UserDelegue
    }

    #$expusers.GetEnumerator() | Export-Csv -Path "C:\New-users.csv" -Delimiter ';' -Append -NoTypeInformation 
    #$expusers | Export-Csv -Path "C:\New-users.csv" -Delimiter ';' -Force -Append -NoTypeInformation
    $expusers | ConvertTo-Csv -Delimiter ';' -NoTypeInformation | % {$_.Replace('"','')} | Out-File "C:\New-users.csv" -Append -NoNewline
    #$expusers| Export-Csv -Path "C:\New-users.csv" -Delimiter ';' -NoTypeInformation -UseCulture -NoQuoteChar
    #$expusers.GetEnumerator() | Export-Csv -Path "C:\New-users.csv" -Delimiter ';' -UseCulture -Append -NoTypeInformation

}

