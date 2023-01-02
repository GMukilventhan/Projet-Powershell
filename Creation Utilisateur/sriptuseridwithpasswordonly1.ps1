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
    $UPN = "$uniqueId@biodevops.local"
    $UserEmail = "$uniqueId@biodevops.eu"
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
$uniqueId = "U$currentYear" + (-join $uniqueRandomNumbers)


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
# Vérifie si l'utilisateur existe déjà
# Vérifie si l'utilisateur existe déjà
$UserExists = Get-ADUser -Filter {SamAccountName -eq $uniqueId} -ErrorAction SilentlyContinue

# Si l'utilisateur existe déjà
if ($UserExists) {
    # Génère un nouveau nom d'utilisateur en ajoutant un numéro au nom de l'utilisateur
    $i = 1
    while ($UserExists) {
        $UserLogon = $UserFirstname.ToLower() + "." + $UserLastname.ToLower() + $i
        $UPN = "$UserLogon@biodevops.local"
        $UserEmail = "$UserLogon@biodevops.eu"
        $UserExists = Get-ADUser -Filter {SamAccountName -eq $uniqueId} -ErrorAction SilentlyContinue
        $i++
        $UserDisplay = "$UserFirstname $UserLastname $i"
    }
}






# Crée l'utilisateur avec le nom d'utilisateur généré (ou original si aucun homonyme n'a été trouvé)

New-ADUser -Name $UserDisplay `
           -GivenName $UserFirstname `
           -Surname $UserLastname `
           -DisplayName $UserDisplay `
           -SamAccountName $uniqueId `
           -UserPrincipalName $UPN `
           -EmailAddress $UserEmail `
           -Title $UserTitle `
           -Department $UserClasse `
           -Company $UserCpny `
           -Path $UserPath `
           -Enabled $true `
           -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) `
           -ChangePasswordAtLogon $true


# Ajoute l'utilisateur aux groupes de sécurité et de distribution
Add-ADPrincipalGroupMembership -Identity $uniqueId -MemberOf $GroupNameSecurity
Add-ADPrincipalGroupMembership -Identity $uniqueId -MemberOf $GroupNameDistribution

# Affiche un message de confirmation
Write-Output "Utilisateur $uniqueId créé avec succès !"
}
$users = @()
$users += New-Object -TypeName PSObject -Property @{
  "Username" = $UserLogon
  "Password" = $password
}
$users | Export-Csv -Path "C:\password.csv" -Append -NoType