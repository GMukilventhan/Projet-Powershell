$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory
Import-Module $PSScriptRoot/Module.psm1

$global:filelogs = "Logs/remove.json"

$users = Get-ADUser -Filter *

foreach ($user in $users) {
    if ($user.Enabled -eq $false) {
        $disableDate = $user.AccountDisabledDate
        $timeSinceDisable = New-TimeSpan -Start $disableDate -End (Get-Date)
        if ($timeSinceDisable.Days -gt 30) {
            Remove-ADUser -Identity $user
            Write-Success -Message "l'utilisateur a été supprimé:" -Commentaire $user
        }
    }else{
        $inactiveDays = 60
        $time = (Get-Date).Adddays(-($inactiveDays))
        if ($user.LastLogonTimeStamp -lt $time){
            Disable-ADAccount -Identity $user
        }
    }
}



