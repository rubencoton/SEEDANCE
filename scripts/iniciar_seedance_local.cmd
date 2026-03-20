@echo off
setlocal
cd /d C:\Users\elrub\Desktop\CARPETA CODEX\01_PROYECTOS\SEEDANCE\RECUPERADO_SIDAM\seedance2.0

set "NPM_CMD=%ProgramFiles%\nodejs\npm.cmd"
set "NPX_CMD=%ProgramFiles%\nodejs\npx.cmd"

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

if not exist node_modules (
  call "%NPM_CMD%" run install:all
)

call "%NPX_CMD%" playwright-core install chromium
call "%NPM_CMD%" run dev
