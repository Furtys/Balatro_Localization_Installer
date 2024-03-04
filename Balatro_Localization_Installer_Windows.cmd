::Script permettant le telechargement automatique de la dernière version de Balamod (https://github.com/UwUDev/balamod) et 
:: du fichier de langue FR créé par la communauté https://github.com/FrBmt-BIGetNouf/balatro-french-translations/.

@echo off
setlocal enabledelayedexpansion

set "colorReset=[0m"
set "resourcesFolder=Balatro_Localization_Resources"

echo =========================================
echo ==             BALATRO MOD             ==
echo ==  Installation du pack de langue FR  ==
echo =========================================

:: On vérifie l'existence du fichier libraryfolders.vdf dans le chemin d'installation par défaut Steam.
set "steamLibraryFile=C:\Program Files (x86)\Steam\steamapps\libraryfolders.vdf"

if not exist "!steamLibraryFile!" (
    :: S'il n'existe pas, on doit demander à l'utilisateur de sélectionner le fichier Balatro.exe lui même.
    echo ==========================================
    echo ==   Steam n'est pas installe dans C:   ==
    echo ==  Merci de bien vouloir selectionner  ==
    echo ==        le fichier Balatro.exe        ==
    echo ==========================================
    
    :: Explorateur de fichier pour que l'utilisateur puisse facilement selectionner le fichier.
    set "balatroFile="
    set "dialogTitle=Selectionner balatro.exe"
    set "fileFilter=Balatro Executable (balatro.exe) | balatro.exe"

    for /f "delims=" %%I in ('powershell -Command "& { Add-Type -AssemblyName System.Windows.Forms; $dlg = New-Object System.Windows.Forms.OpenFileDialog; $dlg.Filter = '!fileFilter!'; $dlg.Title = '!dialogTitle!'; $dlg.ShowHelp = $true; $dlg.ShowDialog() | Out-Null; $dlg.FileName }"') do set "selectedFile=%%I"
    
    if defined selectedFile (
        set "balatroFile=!selectedFile!"
        echo Balatro.exe selectionne : !balatroFile!
    ) else (
        echo == Fichier Balatro.exe non selectionne  ==
        echo ==========================================
        goto :fin
    )
)

:: Si le dossier ressources n'existe pas on le cree.
if not exist "%resourcesFolder%" mkdir "%resourcesFolder%"

:: On recupère le dernier tag de la release de Balamod.
for /f %%a in ('powershell -command "$tag = (Invoke-RestMethod -Uri 'https://api.github.com/repos/UwUDev/balamod/releases/latest').tag_name; $tag"') do set latestTag=%%a

:: Creation des noms et liens des fichiers. Valable uniquement tant que le fichier windows s'appelle bien balamod-v.y.z-windows.exe.
set "balamodFile=balamod-%latestTag%-windows.exe"
set "balamodFileUrl=https://github.com/UwUDev/balamod/releases/download/%latestTag%/%balamodFile%"
set "FR_translationUrl=https://raw.githubusercontent.com/FrBmt-BIGetNouf/balatro-french-translations/main/localization/fr.lua"

:: Si le fichier balamod n'existe pas on le télécharge.
if not exist "%resourcesFolder%\%balamodFile%" (
    echo =========================================
    echo ==      Telechargement de Balamod      ==
    echo =========================================

    curl -L -o "%resourcesFolder%\%balamodFile%" %balamodFileUrl%

    echo =========================================
    echo ==       Telechargement termine.       ==
    echo =========================================
) else (
    echo =========================================
    echo ==        Balamod a jour trouve        ==
    echo =========================================
)

:: On télécharge tout le temps la traduction française.
echo =========================================
echo == Telechargement du fichier de langue ==
echo =========================================

curl -L -o "%resourcesFolder%\fr.lua" %FR_translationUrl%

echo =========================================
echo ==       Telechargement termine.       ==
echo =========================================

:: Execution de l'injection du fichier de langue.
echo =========================================
echo ==  Installation du fichier de langue  ==
echo =========================================

if not defined balatroFile (
    :: Si Steam installé par défaut, on laisse Balamod chercher le fichier Balatro.
    "./%resourcesFolder%\%balamodFile%" -x -i .\%resourcesFolder%\fr.lua -o localization/fr.lua
) else (
    :: Sinon on lui envoie le dossier du fichier Balatro.exe selectionné précédemment.
    for %%A in ("!balatroFile!") do set "balatroFolder=%%~dpA"
    "./%resourcesFolder%\%balamodFile%" -b !balatroFolder! -x -i .\%resourcesFolder%\fr.lua -o localization/fr.lua
)


echo %colorReset%=========================================
echo ==        Installation terminee        ==
echo =========================================

:: Suppression des fichiers ressources si l'utilisateur veut.
choice /C ON /M "Voulez-vous supprimer les fichiers telecharges ?"
if errorlevel 2 goto :fin

:: Si oui, on supprime.
rd /s /q "%resourcesFolder%"
echo Suppression des fichiers terminee

:fin
echo =========================================
echo ==   Fin du programme d'installation   ==
echo =========================================
pause