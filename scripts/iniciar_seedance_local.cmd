@echo off
setlocal EnableExtensions
set "APP_DIR=C:\Users\elrub\Desktop\CARPETA CODEX\01_PROYECTOS\SEEDANCE\RECUPERADO_SIDAM\seedance2.0"
set "APP_URL=http://localhost:5173"

if not exist "%APP_DIR%" (
  echo [ERROR] No existe la carpeta local de Seedance:
  echo %APP_DIR%
  pause
  exit /b 1
)

cd /d "%APP_DIR%"

set "NPM_CMD=%ProgramFiles%\nodejs\npm.cmd"
set "NPX_CMD=%ProgramFiles%\nodejs\npx.cmd"
set "READY_FLAG=%APP_DIR%\\.seedance_local_ready"

if not exist "%NPM_CMD%" (
  echo [ERROR] No se encontro npm.cmd. Instala Node.js y vuelve a intentar.
  pause
  exit /b 1
)

if not exist "%NPX_CMD%" (
  echo [ERROR] No se encontro npx.cmd. Instala Node.js y vuelve a intentar.
  pause
  exit /b 1
)

if not exist ".env" (
  if exist ".env.example" (
    copy /Y ".env.example" ".env" >nul
  )
)

if not exist "%READY_FLAG%" (
  echo [INFO] Primera preparacion local. Puede tardar unos minutos...
  call "%NPM_CMD%" run install:all
  if errorlevel 1 goto :fail
  call "%NPX_CMD%" playwright-core install chromium
  if errorlevel 1 goto :fail
  echo ready>"%READY_FLAG%"
) else (
  if not exist "node_modules" (
    echo [INFO] Dependencias faltantes. Reinstalando...
    call "%NPM_CMD%" run install:all
    if errorlevel 1 goto :fail
  )
)

echo [INFO] Abriendo Seedance local en %APP_URL%
start "" "%APP_URL%"
call "%NPM_CMD%" run dev
exit /b %ERRORLEVEL%

:fail
echo [ERROR] Fallo la preparacion/conexion local de Seedance.
pause
exit /b 1
