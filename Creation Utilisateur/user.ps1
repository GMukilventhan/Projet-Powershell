﻿# Importe le module Active Directory
#Import-Module ActiveDirectory

# Importe les données du fichier CSV
$CSVpath = "C:\Test\user.csv"
$CSVdata = Import-CSV -Path $CSVpath -Delimiter ";" -Encoding Default



# Pour chaque ligne du fichier CSV
foreach ($User in $CSVdata) {

    $UserFirstname = $User.Firstname
    $UserLastname = $User.Lastname.ToUpper()
    $UserDisplay = $UserFirstname + " " + $UserLastname.ToUpper()
    $UserLogon = $UserFirstname.ToLower() + "." + $UserLastname.ToLower()
    $UserPassword = $User.Password
    $UPN = "$UserLogon@biodevops.local"
    $UserEmail = "$UserLogon@biodevops.eu"
    $UserTitle = $User.Title
    $UserCpny = $User.Company
    $UserAnnee = $User.Annee
    $UserAnneeEtude = $User.AnneeEtude
    $UserFiliere = $User.Filiere
    $UserPromotion = $User.Promotion
    $UserClasse = $UserAnnee + "_" + $UserPromotion
    $UserPath = "OU=$UserClasse,OU=$UserFiliere,OU=$UserAnneeEtude,OU=$UserAnnee,OU=ETUDIANTS,OU=BIODEVOPS,DC=mk,DC=lan"

                
    if (Get-ADUser -Filter {SamAccountName -eq $UserLogon})
    {
    Write-Warning "Attention, l'utilisateur $UserLogon existe déjà dans l'annuaire !"
    }
    else    {
    New-ADUser -Name "$UserFirstname $UserLastname"`
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
               -AccountPassword (ConvertTo-SecureString $UserPassword -AsPlainText -Force) `
               -ChangePasswordAtLogon $false `
               -Enabled $true


    Write-Output "Création de l'utilisateur : $UserLogon !"


    }
}



