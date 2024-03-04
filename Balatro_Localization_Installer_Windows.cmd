::Script permettant le telechargement automatique de la dernière version de Balamod (https://github.com/UwUDev/balamod) et 
:: du fichier de langue FR créé par la communauté https://github.com/FrBmt-BIGetNouf/balatro-french-translations/.

@echo off
setlocal enabledelayedexpansion

echo =========================================
echo ==========     BALATRO MOD     ==========
echo === Installation du pack de langue FR ===
echo =========================================

set "color_reset=[0m"
set "dossier_ressources=Balatro_Localization_Resources"

:: Si le dossier ressources n'existe pas on le cree.
if not exist "%dossier_ressources%" mkdir "%dossier_ressources%"

:: On recupère le dernier tag de la release de Balamod.
for /f %%a in ('powershell -command "$tag = (Invoke-RestMethod -Uri 'https://api.github.com/repos/UwUDev/balamod/releases/latest').tag_name; $tag"') do set latestTag=%%a

:: Creation des noms et liens des fichiers. Valable uniquement tant que le fichier windows s'appelle bien balamod-v.y.z.windows.exe.
set "balamodFile=balamod-%latestTag%-windows.exe"
set "balamodFileUrl=https://github.com/UwUDev/balamod/releases/download/%latestTag%/%balamodFile%"
set "FR_translationUrl=https://raw.githubusercontent.com/FrBmt-BIGetNouf/balatro-french-translations/main/localization/fr.lua"

:: Si le fichier balamod n'existe pas on le telecharge.
if not exist "%dossier_ressources%\%balamodFile%" (
    echo =========================================
    echo ======= Telechargement de BALAMOD =======
    echo =========================================

    curl -L -o "%dossier_ressources%\%balamodFile%" %balamodFileUrl%

    echo =========================================
    echo ======== Telechargement termine. ========
    echo =========================================
) else (
    echo =========================================
    echo =======   BALAMOD a jour trouve   =======
    echo =========================================
)

:: On telecharge tout le temps la traduction française.
echo =========================================
echo == Telechargement du fichier de langue ==
echo =========================================

curl -L -o "%dossier_ressources%\fr.lua" %FR_translationUrl%

echo =========================================
echo ======== Telechargement termine. ========
echo =========================================

:: Execution de l'injection du fichier de langue.
echo =========================================
echo === Installation du fichier de langue ===
echo =========================================

"./%dossier_ressources%\%balamodFile%" -x -i "%dossier_ressources%\fr.lua" -o localization/fr.lua

echo %color_reset%=========================================
echo ========= Installation terminee =========
echo =========================================

:: Suppression des fichiers ressources si l'utilisateur veut.
choice /C ON /M "Voulez-vous supprimer les fichiers telecharges ?"
if errorlevel 2 goto :fin

:: Si oui, on supprime.
rd /s /q "%dossier_ressources%"
echo Suppression des fichiers terminee

:fin
pause