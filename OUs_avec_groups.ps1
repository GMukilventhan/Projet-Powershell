Import-Module ActiveDirectory

# Pré-requis script :
# Le fichier CSV dans le chemin indiqué
# Les unités d'organisation parent BIODEVOPS et enfant ETUDIANTS sont crées

# Import du fichier CSV
$CSVpath = "C:\ScriptsBiodevops\biodevops_ou.csv"
$CSVdata = Import-CSV -Path $CSVpath -Delimiter ";" -Encoding Default

# Boucle Foreach pour parcourir le fichier CSV
Foreach($OU in $CSVdata){

$OUname = $OU.name
$OUpath = $OU.path
$OUsecurityGroup = $OU.securitygroup
$OUdistributionGroup = $OU.distributiongroup
$SecurityGroupName = "Grp_Securite_" + $OUname
$DistributionGroupName = "Grp_Distribution_" + $OUname
$GroupPath = "OU=$OUname" + "," + $OUpath

New-ADOrganizationalUnit -Name $OUname -Path $OUpath -ProtectedFromAccidentalDeletion $False
Write-Host "Création de l'unité d'organisation : $OUname"

If(($OUsecurityGroup -eq "true") -and ($OUdistributionGroup -eq "true"))
{ 
  New-ADGroup -Name $SecurityGroupName -Path $GroupPath -GroupScope Global -GroupCategory Security
  Write-Host "Création du groupe de sécurité « $SecurityGroupName » pour la promotion « $OUname »"
  New-ADGroup -Name $DistributionGroupName -Path $GroupPath -GroupScope Global -GroupCategory Distribution
  Write-Host "Création du groupe de distribution « $DistributionGroupName » pour la promotion « $OUname »"
}
Else{
  Write-Host "Cette unité d'organisation n'est pas une promotion, aucun groupe n'est requis..."
}

}