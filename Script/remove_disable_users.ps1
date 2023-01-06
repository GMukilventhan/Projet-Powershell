$ErrorActionPreference = "Stop"

$folder = "C:\Script"
Import-Module ActiveDirectory
Import-Module $folder/Module.psm1
$global:filelogs = $folder + "/Logs/" + "remove.json"


$users = Get-ADUser -Filter *

foreach ($user in $users) {
    if ($user.Enabled -eq $false) {
        $disableDate = $user.AccountDisabledDate
        try {
            $timeSinceDisable = New-TimeSpan -Start $disableDate -End (Get-Date)
        }catch{
            Write-Error -Message "error date" -Commentaire $user 
        }
        
        if ($timeSinceDisable.Days -ge 30) {
            try{
                Remove-ADUser -Identity $user
                Write-Success -Message "l'utilisateur a été supprimé:" -Commentaire $user
            }catch{
                Write-Error -Message "error l'utilisateur $user a ete supprime:" -Commentaire $user        
            }
        }
    }
    <#
    else{
        $inactiveDays = 60
        $time = (Get-Date).Adddays(-($inactiveDays))
        if ($user.LastLogonTimeStamp -lt $time){
            try{
                Disable-ADAccount -Identity $user
                Write-Success -Message "l'utilisateur $user a ete desactive" -Commentaire $user
            }catch{
               Write-Error -Message "impossible de desactive $user " -Commentaire $user     
            }
        }

    }
    #>
}