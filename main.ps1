Import-Module $PSScriptRoot/Module.psm1


# Créer un nouvel objet de la classe Logs en spécifiant le nom du fichier JSON
$logs = [Logs]::new('logs.json')


Try{
    $logs.Info("execution de la commande montest","cette commande va modifier bcp de parametre ")
    montest
}catch{
    $logs.Error("probleme d execution","le probleme viens d un probleme d excution dans le script")
}