
Import-Module ActiveDirectory

function Creation-UO {
  param(
    [string]$NomUO,
    [string]$ParentUO
  )

  if (Get-ADOrganizationalUnit -Filter "Name -eq '$NomUO'" -ErrorAction SilentlyContinue) {
    Write-Host "l'unité d’organisation'$NomUO' existe déjà."-ForegroundColor red
    return
  }

  try {
    New-ADOrganizationalUnit -Name $NomUO -Path $ParentUO
    Write-Host "l'unité d’organisation'$NomUO' a été créé avec succès."-ForegroundColor green
  } catch {
    Write-Host "Erreur lors de la création de l'unité d’organisation '$NomUO': $($Error[0])"-ForegroundColor red
  }

  $creationSousUO = Read-Host "Voulez-vous créer des sous unités d’organisations dans  '$NomUO'? (O/N)"

  while ($creationSousUO -eq "O") {
    $sousNomUO = Read-Host "Entrez le nom de le sous unité d’organisation à créer:"
    Creation-UO -NomUO $sousNomUO -ParentUO "OU=$NomUO,$ParentUO"
    $creationSousUO = Read-Host "Voulez-vous créer des sous OU dans OU '$NomUO'? (O/N)"
  }
}


$mainNomUO = Read-Host "Entrez le nom de l'OU principal à créer:"

Creation-UO -NomUO $mainNomUO -ParentUO "DC=mk,DC=lan"
