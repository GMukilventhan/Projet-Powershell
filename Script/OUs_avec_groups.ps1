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
        Write-Success -Message "Creation de l'unite d'organisation : $OUname" -Commentaire " -Name $OUname -Path $OUpath -ProtectedFromAccidentalDeletion $False"
    }catch{
        Write-Error -Message "ERREUR lors de la creation de l'unite d'organisation : $OUname" -Commentaire " -Name $OUname -Path $OUpath -ProtectedFromAccidentalDeletion $False"
    }

    If(($OUsecurityGroup -eq "true") -and ($OUdistributionGroup -eq "true"))
    { 
        try{
            New-ADGroup -Name $SecurityGroupName -Path $GroupPath -GroupScope Global -GroupCategory Security
            Write-Success -Message "Creation du groupe de securite  $SecurityGroupName � pour la promotion � $OUname �" -Commentaire "-Name $SecurityGroupName -Path $GroupPath -GroupScope Global -GroupCategory Security"
        }catch{
            Write-Error -Message "ERREUR lors de la creation du groupe de securite � $SecurityGroupName � pour la promotion � $OUname �" -Commentaire "-Name $SecurityGroupName -Path $GroupPath -GroupScope Global -GroupCategory Security"
        }  
        $GroupDistributionEmail = $OUname.Split('_')[1] + "." + $OUname.Split('_')[0] + "@biodevops.eu"
        try{
            New-ADGroup -Name $DistributionGroupName -Path $GroupPath -GroupScope Global -GroupCategory Distribution -OtherAttributes @{'mail'= $GroupDistributionEmail}
            Write-Success -Message "Cr�ation du groupe de distribution � $DistributionGroupName � pour la promotion � $OUname � associ� � l'e-mail � $GroupDistributionEmail �" -Commentaire "-Name $DistributionGroupName -Path $GroupPath -GroupScope Global -GroupCategory Distribution -OtherAttributes @{'mail'= $GroupDistributionEmail}"
        }catch{
            Write-Error -Message "ERREUR lors de la cr�ation du groupe de distribution � $DistributionGroupName � pour la promotion � $OUname � associ� à l'e-mail � $GroupDistributionEmail �" -Commentaire "-Name $DistributionGroupName -Path $GroupPath -GroupScope Global -GroupCategory Distribution -OtherAttributes @{'mail'= $GroupDistributionEmail}"
        }
        try{
            Add-ADGroupMember -Identity $DistributionGroupName -Members $SecurityGroupName
            Write-Success -Message "Le groupe de securite � $SecurityGroupName � devient membre du groupe de distribution � $DistributionGroupName �" -Commentaire "-Identity $DistributionGroupName -Members $SecurityGroupName"
        }catch{
            Write-Error -Message "ERREUR lors de l'ajout du groupe de securite � $SecurityGroupName � au groupe de distribution � $DistributionGroupName �" -Commentaire "-Identity $DistributionGroupName -Members $SecurityGroupName"
        }
    }

}
