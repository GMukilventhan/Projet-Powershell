Import-Module ActiveDirectory

# Pré-requis script :
# Le fichier CSV dans le chemin indiqué
# Les unités d'organisation parent BIODEVOPS et enfant ETUDIANTS sont crées

# Import du fichier CSV
$CSVpath = "C:\ScriptsBiodevops\biodevops_ou.csv"


# Boucle Foreach pour parcourir le fichier CSV



function new-OufromCsv {
    param (
        $CSVpath
    )

    $CSVdata = Import-CSV -Path $CSVpath -Delimiter ";" -Encoding Default
    Foreach($OU in $CSVdata){
        $OUname = $OU.name
        $OUpath = $OU.path
        $testOu = Get-ADOrganizationalUnit -LDAPFilter "(name=$(OU.name))" | Format-Table Name
        
        if {$testOu}
        try {
            New-ADOrganizationalUnit -Name $OUname -Path $OUpath
        }catch {
            Write-Host "une erreur est survenu"
            Write-Host $_.Exception.GetType()
        }
    }
}