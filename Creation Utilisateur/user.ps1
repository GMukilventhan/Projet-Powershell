# Importe le module Active Directory
Import-Module ActiveDirectory


# Importe les données du fichier CSV
$CSVpath = "C:\Test\user.csv"
$CSVdata = Import-CSV -Path $CSVpath -Delimiter ";" -Encoding Default

# Pour chaque ligne du fichier CSV
foreach ($User in $CSVdata) {

    $UserFirstname = $User.Firstname
    $UserLastname = $User.Lastname.ToUpper()
    $UserDisplay = $UserFirstname + " " + $UserLastname.ToUpper()
    $UserLogon = $UserFirstname.ToLower() + "." + $UserLastname.ToLower()
    $password = -join (65..90 + 97..122 + 48..57 + 33..47 | Get-Random -Count 8 | %{[char]$_})
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
   $GroupNameSecurity =  "Grp_Securite_" + $UserAnnee + "_" + $UserPromotion
    $GroupNameDistribution = "Grp_Distribution_" + $UserAnnee + "_" + $UserPromotion
    $GroupDistributionEmail = $UserPromotion + "." + $UserAnnee + "@biodevops.eu"
    $GroupPath = "OU=$UserClasse,OU=$UserFiliere,OU=$UserAnneeEtude,OU=$UserAnnee,OU=ETUDIANTS,OU=BIODEVOPS,DC=mk,DC=lan"

   # Vérifie si le groupe de sécurité et distribution  existe déjà
$GroupExists = Get-ADGroup -Filter {Name -eq $GroupNameSecurity} -ErrorAction SilentlyContinue
$GroupExists = Get-ADGroup -Filter {Name -eq $GroupNameDistribution} -ErrorAction SilentlyContinue

# Si le groupe de sécurité n'existe pas, le créer
if (!$GroupExists) {
    New-ADGroup -Name $GroupNameSecurity -Path $UserPath -GroupScope Global -GroupCategory Security
   Write-Output "Création du groupe de securite : $GroupNameSecurity !"
    New-ADGroup -Name $GroupNameDistribution -Path $UserPath -GroupScope Global -GroupCategory Distribution -OtherAttributes @{'mail'= $GroupDistributionEmail}
    Write-Output "Création du groupe de distribution : $GroupNameDistribution !"
}

   
   # Vérifie si l'utilisateur existe déjà
   if (Get-ADUser -Filter {SamAccountName -eq $UserLogon}) {
       Write-Warning "Attention, l'utilisateur $UserLogon existe déjà dans l'annuaire !"

   }
   # Si l'utilisateur n'existe pas, le créer
   else {
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
                  -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) `
                   -ChangePasswordAtLogon $True `
                   -Enabled $true
       Write-Output "Création de l'utilisateur : $UserLogon !"
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
