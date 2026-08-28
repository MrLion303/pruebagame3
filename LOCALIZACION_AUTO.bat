@echo off
setlocal
cd /d "%~dp0"

where py >nul 2>nul
if %errorlevel%==0 (
    py -3 localizacion_sync.py --watch
    goto :eof
)

where python >nul 2>nul
if %errorlevel%==0 (
    python localizacion_sync.py --watch
    goto :eof
)

echo No se encontro Python 3 en PATH.
echo Instala Python 3 o ejecuta localizacion_sync.py con tu instalacion de Python.
pause
