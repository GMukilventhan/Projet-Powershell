$folder = "C:\Script"
Import-Module ActiveDirectory
Import-Module $folder/Module.psm1
# Pré-requis script :
# Le fichier CSV dans le chemin indiqué
# Les unités d'organisation parent BIODEVOPS et enfant ETUDIANTS sont crées

# Import du fichier CSV

$CSVpath = $folder + "\CSV\" +  "OU_PROMOTION.csv"
$CSVdata = Import-CSV -Path $CSVpath -Delimiter ";" -Encoding Default
$global:filelogs = $folder + "/Logs/" + "OU.json"
# Boucle Foreach pour parcourir le fichier CSV
Foreach($OU in $CSVdata){

    $OUname = $OU.name
    $OUpath = $OU.path
    $OUsecurityGroup = $OU.securitygroup
    $OUdistributionGroup = $OU.distributiongroup
    $SecurityGroupName = "Grp_Securite_" + $OUname
    $DistributionGroupName = "Grp_Distribution_" + $OUname
    $GroupPath = "OU=$OUname" + "," + $OUpath
    try{
        New-ADOrganizationalUnit -Name $OUname -Path $OUpath -ProtectedFromAccidentalDeletion $False
        Write-Success -Message "Création de l'unité d'organisation : $OUname" -Commentaire " -Name $OUname -Path $OUpath -ProtectedFromAccidentalDeletion $False"
    }catch{
        Write-Error -Message "Création de l'unité d'organisation error: $OUname" -Commentaire " -Name $OUname -Path $OUpath -ProtectedFromAccidentalDeletion $False"
    }

    If(($OUsecurityGroup -eq "true") -and ($OUdistributionGroup -eq "true"))
    { 
        try{
            New-ADGroup -Name $SecurityGroupName -Path $GroupPath -GroupScope Global -GroupCategory Security
            Write-Success -Message "Création du groupe de sécurité « $SecurityGroupName » pour la promotion « $OUname »" -Commentaire "-Name $SecurityGroupName -Path $GroupPath -GroupScope Global -GroupCategory Security"
        }catch{
            Write-Error -Message "Création du groupe de sécurité « error $SecurityGroupName » pour la promotion « $OUname »" -Commentaire "-Name $SecurityGroupName -Path $GroupPath -GroupScope Global -GroupCategory Security"
        }  
        $GroupDistributionEmail = $OUname.Split('_')[1] + "." + $OUname.Split('_')[0] + "@biodevops.eu"
        try{
            New-ADGroup -Name $DistributionGroupName -Path $GroupPath -GroupScope Global -GroupCategory Distribution -OtherAttributes @{'mail'= $GroupDistributionEmail}
            Write-Success -Message "Création du groupe de distribution « $DistributionGroupName » pour la promotion « $OUname » associé à l'e-mail « $GroupDistributionEmail »" -Commentaire "-Name $DistributionGroupName -Path $GroupPath -GroupScope Global -GroupCategory Distribution -OtherAttributes @{'mail'= $GroupDistributionEmail}"
        }catch{
            Write-Error -Message "Création du groupe de distribution « $DistributionGroupName » pour la promotion « $OUname » associé à l'e-mail « $GroupDistributionEmail »" -Commentaire "-Name $DistributionGroupName -Path $GroupPath -GroupScope Global -GroupCategory Distribution -OtherAttributes @{'mail'= $GroupDistributionEmail}"
        }
        try{
            Add-ADGroupMember -Identity $DistributionGroupName -Members $SecurityGroupName
            Write-Success -Message "Le groupe de sécurité « $SecurityGroupName » devient membre du groupe de distribution « $DistributionGroupName »" -Commentaire "-Identity $DistributionGroupName -Members $SecurityGroupName"
        }catch{
            Write-Error -Message "Le groupe de sécurité « $SecurityGroupName »  error devient membre du groupe de distribution « $DistributionGroupName »" -Commentaire "-Identity $DistributionGroupName -Members $SecurityGroupName"
        }
    }

}
