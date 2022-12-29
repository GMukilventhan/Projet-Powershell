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

New-ADOrganizationalUnit -Name $OUname -Path $OUpath

}