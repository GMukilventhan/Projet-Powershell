$users = Import-Csv -Path "C:\users.csv"

foreach ($user in $users) {
  # Récupére l'objet utilisateur correspondant dans Active Directory
  $adUser = Get-ADUser -Identity $user.Username -ErrorAction SilentlyContinue
  if ($adUser) {
    # Désactive l'utilisateur s'il existe dans Active Directory
    Disable-ADAccount -Identity $adUser
  }
}