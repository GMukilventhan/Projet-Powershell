

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
    Write-Host "-Type Warning -Message $Message -Commentaire $Commentaire" -ForegroundColor Gray
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
                New-ADOrganizationalUnit -Name $OUname -Path $OUpath
                Write-Success -Message "Nouvelle OU $OUname" -Commentaire "$OUname $OUpath"
        }catch {
            Write-Error -Message "erreur lors de la creation de $OUname $($_.Exception.GetType())" -Commentaire "$OUname $OUpath"
        }
    }
}




function test-userexists {
            param(
                $Parameter,
                $Identity
            )
            $result = Get-ADUser -Filter {$Parameter -eq $Identity}
            if ($result) {
                return $True 
            }else{
                return $False
            }
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

    # Pour chaque UO ou sous-UO crï¿½e un groupe de sï¿½curitï¿½ ou un groupe de distribution
    foreach ($ou in $ous){
        $groupName = $ou.Name
        if ($GroupType -eq "Security"){
            New-ADGroup -Name $groupName -Path $ou.DistinguishedName -GroupCategory $GroupCategory -GroupScope $GroupScope
        }
        elseif ($GroupType -eq "Distribution"){
            New-ADGroup -Name $groupName -Path $ou.DistinguishedName -GroupCategory "Distribution" -GroupScope $GroupScope
        }
    }
    <#
    foreach ($group in $groups){
        foreach ($user in $users){
            if ($user.Department -eq $group.Name){
                Add-ADGroupMember -Identity $group -Members $user
            }
        }
    }
    #>
}







<#
Lors de chaque Ã©lection du dÃ©lÃ©guÃ© de la promotion, 
lâ€™ensemble des comptes des Ã©lÃ¨ves sont mis Ã  jour afin de modifier la valeur Â« manager Â» 
des Ã©lÃ¨ves avec la valeur du DistinguishedName du compte de lâ€™Ã©lÃ¨ve promu en tant que dÃ©lÃ©guÃ©.

objectif recupÃ©rÃ© le nom du dÃ©lÃ©guÃ© puis son ou
lister les nombre utilisateur de l'ou sans lui meme
puis ajouter le nom du dÃ©lÃ©guÃ© dans la variable manager

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