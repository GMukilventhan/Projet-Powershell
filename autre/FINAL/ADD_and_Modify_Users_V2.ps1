$ErrorActionPreference = "Stop"
#Import Module
Import-Module ActiveDirectory
Import-Module $PSScriptRoot/Module.psm1

#action tracer sur LOG
$global:filelogs = "Logs/Modif.json"

# Importe les donnees du fichier CSV
$CSVpath = "C:\Git\CSV\user.csv"
$CSVdata = Import-CSV -Path $CSVpath -Delimiter ";" -Encoding Default

# Parcourir chaque ligne du fichier CSV
foreach ($User in $CSVdata) {
    $UserSAM = $User.SAM
    $UserFirstname = $User.Firstname
    $UserLastname = $User.Lastname.ToUpper()
    $UserDisplay = $UserFirstname + " " + $UserLastname.ToUpper()
    $UserFirstnameLastname = $UserFirstname.ToLower() + "." + $UserLastname.ToLower()
    $password = -join (65..90 + 97..122 + 48..57 + 33..47 | Get-Random -Count 12 | %{[char]$_})
    $password = $password + "$"
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
    $GrpSAMameSecurity =  "Grp_Securite_" + $UserAnnee + "_" + $UserPromotion
    $GrpSAMameDistribution = "Grp_Distribution_" + $UserAnnee + "_" + $UserPromotion
    $GroupDistributionEmail = $UserPromotion + "." + $UserAnnee + "@biodevops.eu"
    $GroupPath = "OU=$UserClasse,OU=$UserFiliere,OU=$UserAnneeEtude,OU=$UserAnnee,OU=ETUDIANTS,OU=BIODEVOPS,DC=mk,DC=lan"

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


    
    if ($UserSAM -eq "Null"){  
        $uniqueRandomNumbers = -join (0..9| Get-Random -Count 10)
        $UniqueId = "U" + $UserAnnee + (-join $uniqueRandomNumbers)          
        $i = 1
        $testuser = test-userexists -Identity $UserDisplay -Parameter "Name"
        $OriginalUserFirstnameLastname = $UserFirstnameLastname
        $OriginalUserDisplay = $UserDisplay
        $UniqueId
  
        while ($testuser -eq $True) {
   
            $UserFirstnameLastname = $OriginalUserFirstnameLastname + $i
            $UPN = $UserFirstnameLastname + "@biodevops.local"
            $UserEmail = $UserFirstnameLastname + "@biodevops.eu"
            
            $UserDisplay = $OriginalUserDisplay + $i
            $testuser = test-userexists -Identity $UserDisplay -Parameter "Name"
            $i++
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
            $UniqueId

            Write-Success -Message "crÃƒÂ©ation de l'utilisateur :" -Commentaire $UserDisplay
            $users = @()
            $users += New-Object -TypeName PSObject -Property @{
            "Identifiant" = $UPN
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

        $UniqueId

    }else {
        $UniqueId = $UserSAM
        $UniqueId
        if (test-userexists -Identity $UniqueId -Parameter "SamAccountName") {
            $InfoADFirstname = $user.givenName
            $InfoADLastname = $User.sn
            $InfoADUserActivation = $user.Enabled
            $InfoADUserDelegue = $user.Title 
            
            if($UserDelegue -eq $True){
                $DelegueMemberOf = Get-ADPrincipalGroupMembership $UniqueId | Where-Object {$_.name -like "Grp_Securite_*"}
                # R�cup�rer le nom de l'utilisateur et son SAMaccountName
                $AllMembersGroup = Get-ADGroupMember -Identity $DelegueMemberOf.Name
 
                foreach ($MemberGroup in $AllMembersGroup) {
                    If($MemberGroup.SamAccountName -ne $UserSAM){
                        # Ajouter le le nom du d�l�gu� en tant que manager pour les autres membres de son groupe
                        try { 
                            Set-ADUser -Identity $MemberGroup -Manager $UserSAM
                            write-success -Message "Modification du manager de l'utilisateur :" -Commentaire $MemberGroup
                        }catch {
                            
                            Write-Error -Message "Modification du manager de l'utilisateur impossible:" -Commentaire $MemberGroup
                        }
                    }Else{
                        # Changer le champs Title actuellement Etudiant par Delegue
                        try {
                            Set-ADUser -Identity $UserSAM -Title "Delegue"
                            Write-Success -Message "Modification du titre de l'utilisateur :$UserSAM" -Commentaire $UserDisplay
                        }catch {
                            Write-Error -Message "Modification du titre de l'utilisateur impossible:$UserSAM" -Commentaire $UserDisplay
                        }
                        
                    }
                }
            }
            if ($InfoADFirstname -ne $UserFirstname) {
                try {
                    Set-ADUser -Identity $UniqueId -GivenName $UserFirstname
                    Set-ADUser -Identity $UniqueId -EmailAddress $UserEmail
                    Set-ADUser -Identity $UniqueId -DisplayName $UserDisplay
                    Set-ADUser -Identity $UniqueId -UserPrincipalName $UPN
                    Write-Success -Message "Modification du prÃƒÂ©nom de l'utilisateur :" -Commentaire $UserDisplay
                }catch {
                    $_
                    Write-Warning -Message "Modification du prÃƒÂ©nom de l'utilisateur impossible:" -Commentaire $UserDisplay
                }
            }
            if ($InfoADLastname -ne $UserLastname) {
                try {
                    Set-ADUser -Identity $UniqueId -Surname $UserLastname
                    Set-ADUser -Identity $UniqueId -EmailAddress $UserEmail
                    Set-ADUser -Identity $UniqueId -DisplayName $UserDisplay
                    Set-ADUser -Identity $UniqueId -UserPrincipalName $UPN
                   
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
                    Write-Warning -Message "Modification de l'activation de l'utilisateur impossible:" -Commentaire $UserDisplay
                }
            }
        }else{
            echo "error"
        }
    }
    $UniqueId
    #export tous les champs generer dans un fichier csv
    $expusers = @()
    $expusers += New-Object -TypeName PSObject -Property @{ 
    "SAM" = $UniqueId   
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
   #$expusers.GetEnumerator() | Export-Csv -Path "C:\New-users.csv" -Delimiter ';' -Append -NoTypeInformation 
    $nomcsv = "C:\New-users-" + (Get-Date).ToString("dd-MM-yyyy-HH-mm-ss") + ".csv"
    $expusers | Export-Csv -Path $nomcsv -Delimiter ';' -Append -NoType



}

