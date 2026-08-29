@echo off
setlocal
title Localizacion GameMaker

cd /d "%~dp0"

echo ================================================
echo LOCALIZACION GAMEMAKER
echo ================================================
echo.
echo Proyecto:
echo %CD%
echo.

dir /b "*.yyp" >nul 2>nul
if errorlevel 1 (
    echo [ERROR] No encontre un archivo .yyp en esta carpeta.
    echo Pon este BAT y localizacion_sync_fallback.ps1 junto al .yyp.
    echo.
    pause
    exit /b 1
)

if not exist "%~dp0localizacion_sync_fallback.ps1" (
    echo [ERROR] Falta localizacion_sync_fallback.ps1
    echo Debe estar junto a este BAT.
    echo.
    pause
    exit /b 1
)

echo Usando sincronizador PowerShell sin Python.
echo Los JSON se escribiran en UTF-8 SIN BOM.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0localizacion_sync_fallback.ps1" -Watch

echo.
echo El sincronizador se detuvo.
pause
