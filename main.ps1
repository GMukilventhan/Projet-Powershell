$ErrorActionPreference = "Stop"

<#
    .SYNOPSIS
    # Cette classe permet de gérer les journaux d'application dans un fichier JSON

    .DESCRIPTION
    Cette classe permet de gérer les journaux d'application en enregistrant des entrées de journal dans un fichier JSON. Elle fournit des méthodes pour enregistrer des entrées de journal de différents types (erreur, info, avertissement, succès) et pour afficher le contenu du fichier JSON.

    .PARAMETER filejson
    Description du paramètre
    Le paramètre `filejson` représente le chemin d'accès au fichier JSON de journaux.

    .EXAMPLE
    # Créez une nouvelle instance de la classe en spécifiant le chemin d'accès au fichier JSON de journaux
    $logs = [Logs]::new("C:\mon_log.json")

    # Enregistrez une entrée de journal de type "erreur" avec un message et un commentaire
    $logs.Error("Erreur critique", "Une erreur critique s'est produite")

    # Affichez le contenu du fichier JSON de journaux
    $logs.Getlogs()

    .NOTES
    Notes générales
#>

class Logs {
    [string]$filejson

    Logs([string]$filejson) {
        $this.filejson = $filejson
    }

    Setlogs([string]$Type,[string]$Message,[string]$Commentaire) {
        $date = Get-Date -Format "MM/dd/yyyy HH:mm K"
        $data = @{
            $date = @{
                'Type' = $Type;
                'Message' = $Message;
                'Commentaire' = $Commentaire;
            };
        }

        $json = $data | ConvertTo-Jso
        $json | Out-File -FilePath $this.filejson
    }

    Error([string]$Message,[string]$Commentaire) {
            $this.Setlogs('Error',$Message,$Commentaire)
    }
    Info([string]$Message,[string]$Commentaire) {
        $this.Setlogs('Info',$Message,$Commentaire)
    }
    Warning([string]$Message,[string]$Commentaire) {
        $this.Setlogs('Warning',$Message,$Commentaire)
    }
    Success([string]$Message,[string]$Commentaire) {
        $this.Setlogs('Success',$Message,$Commentaire)
    }


    [string] Getlogs() {
        return Get-Content -Path $this.filejson
    }
}




