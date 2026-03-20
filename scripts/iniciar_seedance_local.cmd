@echo off
setlocal EnableExtensions
set "APP_DIR=C:\Users\elrub\Desktop\CARPETA CODEX\01_PROYECTOS\SEEDANCE\RECUPERADO_SIDAM\seedance2.0"
set "APP_URL=http://localhost:5173"
set "LOG_DIR=%APP_DIR%\logs"

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

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>nul

set "P3001=0"
set "P5173=0"
netstat -ano | findstr /R /C:":3001 .*LISTENING" /C:":3001 .*ESCUCHANDO" >nul && set "P3001=1"
netstat -ano | findstr /R /C:":5173 .*LISTENING" /C:":5173 .*ESCUCHANDO" >nul && set "P5173=1"

if "%P3001%"=="0" (
  echo [INFO] Iniciando servidor API en puerto 3001...
  start "Seedance Server" /min cmd /c "\"%NPM_CMD%\" run dev:server"
) else (
  echo [INFO] Servidor API ya activo en puerto 3001.
)

if "%P5173%"=="0" (
  echo [INFO] Iniciando cliente web en puerto 5173...
  start "Seedance Client" /min cmd /c "\"%NPM_CMD%\" run dev:client"
) else (
  echo [INFO] Cliente web ya activo en puerto 5173.
)

echo [INFO] Abriendo Seedance local en %APP_URL%
start "" "%APP_URL%"
echo [OK] Seedance local lanzado.
exit /b 0

:fail
echo [ERROR] Fallo la preparacion/conexion local de Seedance.
pause
exit /b 1
