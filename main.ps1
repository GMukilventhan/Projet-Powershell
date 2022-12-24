$ErrorActionPreference = "Stop"
Import-Module $PSScriptRoot/Module.psm1
$filelogs = "logs.json"
Write-Success -Message "pas d'erreur" -Commentaire "mon super commentaire" -FilePath $filelogs
