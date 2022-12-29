Import-Module ActiveDirectory

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
        [string]$Commentaire,
        [string]$FilePath
    )
    Write-Host "-Type Error -Message $Message -Commentaire $Commentaire" -ForegroundColor Red
    Write-Logs -Type "Error" -Message $Message -Commentaire $Commentaire -FilePath $FilePath
}
function Write-Info {
    param(
        [string]$Message,
        [string]$Commentaire,
        [string]$FilePath
    )
    Write-Host "-Type Info -Message $Message -Commentaire $Commentaire" -ForegroundColor Blue
    Write-Logs -Type "Info" -Message $Message -Commentaire $Commentaire -FilePath $FilePath
}

function Write-Warning {
    param(
        [string]$Message,
        [string]$Commentaire,
        [string]$FilePath
    )
    Write-Host "-Type Warning -Message $Message -Commentaire $Commentaire" -ForegroundColor Orange
    Write-Logs -Type "Warning" -Message $Message -Commentaire $Commentaire -FilePath $FilePath
}
function Write-Success {
    param(
        [string]$Message,
        [string]$Commentaire,
        [string]$FilePath
    )
    Write-Host "-Type Success -Message $Message -Commentaire $Commentaire" -ForegroundColor Green
    Write-Logs -Type "Success" -Message $Message -Commentaire $Commentaire -FilePath $FilePath
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
            Write-Success -Message "Nouvelle OU $OUname" -Commentaire "$OUname $OUpath" -FilePath $filelogs
        }catch {
            Write-Success -Message "erreur lors de la création de $OUname $($_.Exception.GetType())" -Commentaire "$OUname $OUpath" -FilePath $filelogs
        }
    }
}