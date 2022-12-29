Import-Module ActiveDirectory

# Pré-requis script :
# Le fichier CSV dans le chemin indiqué
# Les unités d'organisation parent BIODEVOPS et enfant ETUDIANTS sont crées

# Import du fichier CSV
$CSVpath = "ou_csv_NOM_A_MODIFIER.csv"


# Boucle Foreach pour parcourir le fichier CSV


function New-OufromCsv {
    param (
        $CSVpath
    )

    $CSVdata = Import-CSV -Path $CSVpath -Delimiter ";" -Encoding Default
    Foreach($OU in $CSVdata){
        $OUname = $OU.name
        $OUpath = $OU.path
        $testOu = Get-ADOrganizationalUnit -LDAPFilter 'name='$OU.name
        if ($null -eq $testOu){
            Write-Output 'coucou'
        }else {
                        try {
                New-ADOrganizationalUnit -Name $OUname -Path $OUpath
            }catch {
                Write-Host "une erreur est survenu"
                Write-Host $_.Exception.GetType()
            }
        }
    }
}

New-OufromCsv -CSVpath $CSVpath

<#


$ous = Get-ADOrganizationalUnit -Filter * | Sort-Object Name

foreach ($ou in $ous)
{
    $groupName = "Distribution Group - $($ou.Name)"
    New-ADGroup -Name $groupName -Type Distribution -Path $ou.DistinguishedName
    Write-Host "Group $groupName created in OU $($ou.Name)"
}#>