# Déclaration de la variable globale
$global:variable = "valeur"

# Définition de la fonction qui utilise la variable globale
function MaFonction {
    Write-Output $global:variable
}

# Appel de la fonction
MaFonction