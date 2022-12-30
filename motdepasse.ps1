$password = -join (65..90 + 97..122 + 48..57 + 33..47 | Get-Random -Count 8 | %{[char]$_})
$idunique = "mowazane"

New-ADUser -Name "wazane mohamed" -SamAccountName $idunique -UserPrincipalName "mowazane@biodevops.eu" -GivenName "mohamed" -Surname "wazane" -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force) -Enabled $true -Path "OU=Utilisateurs,DC=BIODEVOPS,DC=INFRA"

 

$user = @{
  "Username" = $idunique
  "Password" = $password
}
$user.GetEnumerator() | Export-Csv -Path "C:\password.csv" -NoTypeInformation 