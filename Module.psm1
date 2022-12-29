

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
function add-allgroupdistribution {

    $ous = Get-ADOrganizationalUnit -Filter * | Sort-Object Name

    foreach ($ou in $ous)
    {
        $groupName = "Distribution Group - $($ou.Name)"
        New-ADGroup -Name $groupName -Type Distribution -Path $ou.DistinguishedName
        Write-Host "Group $groupName created in OU $($ou.Name)"
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
