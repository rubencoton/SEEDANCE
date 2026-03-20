@echo off
setlocal EnableExtensions

set "APP_ROOT=C:\Users\elrub\Desktop\CARPETA CODEX\01_PROYECTOS\SEEDANCE\APP_LOCAL_CERO"
set "VENV_DIR=%APP_ROOT%\.venv_local_cero"
set "PYTHON_EXE=python"
set "MODEL_ID=THUDM/CogVideoX1.5-5B"
set "APP_URL=http://127.0.0.1:7860"
set "READY_FLAG=%APP_ROOT%\.ready_local_cero"

if not exist "%APP_ROOT%" (
  echo [ERROR] No existe APP_ROOT:
  echo %APP_ROOT%
  pause
  exit /b 1
)

cd /d "%APP_ROOT%"

set "P7860=0"
netstat -ano | findstr /R /C:":7860 .*LISTENING" /C:":7860 .*ESCUCHANDO" >nul && set "P7860=1"
if "%P7860%"=="1" (
  echo [INFO] App local ya activa en puerto 7860.
  start "" "%APP_URL%"
  exit /b 0
)

if not exist "%VENV_DIR%\Scripts\python.exe" (
  echo [INFO] Creando entorno virtual...
  %PYTHON_EXE% -m venv "%VENV_DIR%"
  if errorlevel 1 goto :fail
)

echo [INFO] Activando entorno...
call "%VENV_DIR%\Scripts\activate.bat"
if errorlevel 1 goto :fail

if not exist "%READY_FLAG%" (
  echo [INFO] Instalando dependencias (primera vez)...
  python -m pip install --upgrade pip
  python -m pip install -r requirements.txt
  if errorlevel 1 goto :fail
  echo ok>"%READY_FLAG%"
) else (
  echo [INFO] Dependencias ya preparadas.
)

set "SEEDANCE_LOCAL_MODEL=%MODEL_ID%"

echo [INFO] Abriendo app local en %APP_URL%
start "" "%APP_URL%"

echo [INFO] Iniciando SEEDANCE RUBEN COTON - CERO...
python app_seedance_ruben_coton.py
exit /b %ERRORLEVEL%

:fail
echo [ERROR] Fallo el arranque local.
pause
exit /b 1
