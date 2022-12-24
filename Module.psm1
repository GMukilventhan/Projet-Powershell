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
    Write-Logs -Type "Error" -Message $Message -Commentaire $Commentaire -FilePath $FilePath
}
function Write-Info {
    param(
        [string]$Message,
        [string]$Commentaire,
        [string]$FilePath
    )
    Write-Logs -Type "Info" -Message $Message -Commentaire $Commentaire -FilePath $FilePath
}

function Write-Warning {
    param(
        [string]$Message,
        [string]$Commentaire,
        [string]$FilePath
    )
    Write-Logs -Type "Warning" -Message $Message -Commentaire $Commentaire -FilePath $FilePath
}
function Write-Success {
    param(
        [string]$Message,
        [string]$Commentaire,
        [string]$FilePath
    )
    Write-Logs -Type "Success" -Message $Message -Commentaire $Commentaire -FilePath $FilePath
}

# 2 possibilité sois je met le type derreur directement dans la fonction sois je met sans en sachant que si  je met les erreur directement
# a toi de choisir tu prefaire quoi 
# ducoup j'ai viré la class trop relou ducoup on va garder le fichier psm1

Write-Error -Message "Error message" -Commentaire "Commentaire" -FilePath "logs.json"
Write-Info -Message "Info message" -Commentaire "Commentaire" -FilePath "logs.json"
Write-Success -Message "Success message" -Commentaire "Commentaire" -FilePath "logs.json"
Write-Warning -Message "Warning message" -Commentaire "Commentaire" -FilePath "logs.json"

Write-Logs -Type "Error" -Message "Error message" -Commentaire "Commentaire" -FilePath "logs.json"
