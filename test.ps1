# Demande de saisie d'un mot de passe
$motDePasse = Read-Host -AsSecureString "Entrez votre mot de passe :"

# Conversion du mot de passe en chaîne de caractères
$motDePasseChaine = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($motDePasse))

# Affichage du mot de passe
Write-Output "Votre mot de passe est : $motDePasseChaine"