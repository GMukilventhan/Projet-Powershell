
Import-Module ADSync

# Lance la synchronisation delta 
Start-ADSyncSyncCycle -PolicyType Delta
