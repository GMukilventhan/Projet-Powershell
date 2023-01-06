$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory
Import-Module $PSScriptRoot/Module.psm1

$global:filelogs = "Logs/OU.json"

$CSVpath = "OU_PROMOTION.csv"
New-OufromCsv -CSVpath $CSVpath