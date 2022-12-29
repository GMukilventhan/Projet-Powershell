$ErrorActionPreference = "Stop"
Import-Module $PSScriptRoot/Module.psm1
global $filelogs = "logs.json"
Write-Success -Message "pas d'erreur" -Commentaire "mon super commentaire" -FilePath $filelogs
test-OUexist -OUname "test"
$?