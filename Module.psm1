

#
# LOGS
#
function Write-Logs {
    [CmdletBinding()]
    param(
        [string]$Type,
        [string]$Message,
        [string]$Commentaire,
        [string]$FilePath
    )

    $date = Get-Date -Format "MM/dd/yyyy HH:mm K"
    $data = @{
        $date = @{
            'Type' = $Type;
            'Message' = $Message;
            'Commentaire' = $Commentaire;
        };
    }

    $json = $data | ConvertTo-Json
    $json | Out-File -FilePath $FilePath -Append
}

function Write-Error {
    param(
        [string]$Message,
        [string]$Commentaire
    )
    Write-Host "-Type Error -Message $Message -Commentaire $Commentaire" -ForegroundColor Red
    Write-Logs -Type "Error" -Message $Message -Commentaire $Commentaire -FilePath $global:filelogs
}
function Write-Info {
    param(
        [string]$Message,
        [string]$Commentaire
    )
    Write-Host "-Type Info -Message $Message -Commentaire $Commentaire" -ForegroundColor Blue
    Write-Logs -Type "Info" -Message $Message -Commentaire $Commentaire -FilePath $global:filelogs
}

function Write-Warning {
    param(
        [string]$Message,
        [string]$Commentaire
    )
    Write-Host "-Type Warning -Message $Message -Commentaire $Commentaire" -ForegroundColor Orange
    Write-Logs -Type "Warning" -Message $Message -Commentaire $Commentaire -FilePath $global:filelogs
}
function Write-Success {
    param(
        [string]$Message,
        [string]$Commentaire

    )
    Write-Host "-Type Success -Message $Message -Commentaire $Commentaire" -ForegroundColor Green
    Write-Logs -Type "Success" -Message $Message -Commentaire $Commentaire -FilePath $global:filelogs
}
#momo
function add-Groups-distrib-securityFromOUs
{
  param(
    [Parameter(Mandatory=$true)]
    [string]$RootOU,
    [Parameter(Mandatory=$true)]
    [string]$GroupType,
    [Parameter(Mandatory=$false)]
    [string]$GroupScope = "Global",
    [Parameter(Mandatory=$false)]
    [string]$GroupCategory = "Security"
  )

  # liste des UO et sous-UO sous la racine
  $ous = Get-ADOrganizationalUnit -Filter * -SearchBase $RootOU

  # Pour chaque UO ou sous-UO cr�e un groupe de s�curit� ou un groupe de distribution
  foreach ($ou in $ous)
  {
    $groupName = $ou.Name
    if ($GroupType -eq "Security")
    {
      New-ADGroup -Name $groupName -Path $ou.DistinguishedName -GroupCategory $GroupCategory -GroupScope $GroupScope
    }
    elseif ($GroupType -eq "Distribution")
    {
      New-ADGroup -Name $groupName -Path $ou.DistinguishedName -GroupCategory "Distribution" -GroupScope $GroupScope
    }
  }
}



function test-OUexist {
    param (
        $OUname
    )

    $ou = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouName'"
    if ($ou) {
        return $true
    }else{
        return $false
    }
}

function New-OufromCsv {
    param (
        $CSVpath
    )
    $CSVdata = Import-CSV -Path $CSVpath -Delimiter ";" -Encoding Default
    Foreach($OU in $CSVdata){
        $OUname = $OU.name
        $OUpath = $OU.path

        try {        
            if (test-OUexist){
                New-ADOrganizationalUnit -Name $OUname -Path $OUpath
                Write-Success -Message "Nouvelle OU $OUname" -Commentaire "$OUname $OUpath"
            }else{
                Write-Info -Message "existe deja $OUname" -Commentaire "$OUname $OUpath"
            }
        }catch {
            Write-Success -Message "erreur lors de la création de $OUname $($_.Exception.GetType())" -Commentaire "$OUname $OUpath"
        }
    }
}


<#
Lors de chaque élection du délégué de la promotion, 
l’ensemble des comptes des élèves sont mis à jour afin de modifier la valeur « manager » 
des élèves avec la valeur du DistinguishedName du compte de l’élève promu en tant que délégué.

objectif recupéré le nom du délégué puis son ou
lister les nombre utilisateur de l'ou sans lui meme
puis ajouter le nom du délégué dans la variable manager

#>
function set-newdelege {
    param (
        $Name_user_master
    )

    $User_master = Get-ADUser -Filter "SamAccountName -eq $Name_user_master"
    #$User_master.OU
    #get op user

    Get-ADUser -SearchBase "OU=Utilisateurs,DC=example,DC=com" | ForEach-Object{
        if ($_.Utilisateurs -ne $User_master.name){
            $_.Utilisateurs

            # ajout variable
        }
    }
    

}

