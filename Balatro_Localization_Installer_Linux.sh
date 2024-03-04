#!/bin/bash

#Script permettant le telechargement automatique de la dernière version de Balamod (https://github.com/UwUDev/balamod) et 
# du fichier de langue FR créé par la communauté https://github.com/FrBmt-BIGetNouf/balatro-french-translations/.

color_reset=$'\033[0m'

dossier_ressources=$'Balatro_Localization_Resources'

# Téléchargement de balamod depuis le repo Github.
download_balamod() {
    echo "========================================="
    echo "======= Téléchargement de BALAMOD ======="
    echo "========================================="
    # URL du GitHub et de l'api.
    github_url="https://github.com/UwUDev/balamod"
    github_api_url="https://api.github.com/repos/UwUDev/balamod"

    # On obtient les données de la dernière release via l'API Github.
    json_latest_release=$(curl -s "${github_api_url}/releases/latest")

    # Recherche du nom de la dernière release.
    latest_release=$( echo $json_latest_release | grep -oP 'tag/\K[^"]+')

    # Recherche du nom du fichier linux dans la dernière release (valable tant que UwUDev laisse linux dans le nom du fichier).
    balamod_linux_file=$( echo $json_latest_release | jq -r '.assets[] | select(.name | contains("linux")).name')

    # URL de téléchargement du fichier.
    linux_file_url="${github_url}/releases/download/${latest_release}/${balamod_linux_file}"

    # Vérifie si le fichier existe déjà dans le dossier courant
    if [ -e "${dossier_ressources}/${balamod_linux_file}" ]; then
            echo "========================================="
            echo "${balamod_linux_file} existe déjà dans le dossier courant."
    else
        # Télécharge le fichier Linux
        curl --create-dirs -o "${dossier_ressources}/${balamod_linux_file}" -LJ "${linux_file_url}"
        chmod +x "${dossier_ressources}/${balamod_linux_file}"
        echo "========================================="
        echo "======== Téléchargement terminé. ========"
    fi
    echo "========================================="
}

# Telechargement de la traduction FR pour Balatro.
download_fr_lua() {
    echo "========================================="
    echo "== Telechargement du fichier de langue =="
    echo "========================================="
    # URL du fichier fr.lua
    URL_fichier="https://raw.githubusercontent.com/FrBmt-BIGetNouf/balatro-french-translations/main/localization/fr.lua"

    # Télécharge le fichier fr.lua
    echo "Téléchargement du fichier fr.lua"
    curl --create-dirs -o "${dossier_ressources}/fr.lua" -LJ "${URL_fichier}"
    echo "========================================="
    echo "======== Téléchargement terminé. ========"
    echo "========================================="
}

# Fonction pour injecter le fichier fr.lua dans Balatro
inject_file() {
    # Vérifie si le fichier balamod-linux existe
    if [ -e "${dossier_ressources}/${balamod_linux_file}" ] && [ -e "${dossier_ressources}/fr.lua" ]; then
        echo "========================================="
        echo "=== Installation du fichier de langue ==="
        echo "========================================="
        ./$dossier_ressources/$balamod_linux_file -x -i $dossier_ressources/fr.lua -o localization/fr.lua
    else
        echo "Le fichier ${balamod_linux_file} n'a pas été trouvé. Une erreur lors du téléchargement a du se produire."
    fi
    echo "${color_reset}========================================="    
    echo "== Voulez-vous supprimer les fichiers  =="
    echo "==         téléchargés ? [O/N]         =="
    read -r saisie

    if [[ "$saisie" =~ ^[Oo]$ ]]; then
        echo "Suppression des fichiers..."
        rm -R $dossier_ressources
    elif [[ "$saisie" =~ ^[Nn]$ ]]; then
        echo "Aucun fichier ne sera supprimé."
    else
        echo "Entrée non valide. Aucun fichier n'a été supprimé."
    fi
    echo "========================================="
    echo "========= Installation terminée ========="
    echo "========================================="
}

echo "========================================="
echo "==========     BALATRO MOD     =========="
echo "=== Installation du pack de langue FR ==="
echo "========================================="

download_balamod
download_fr_lua
inject_file