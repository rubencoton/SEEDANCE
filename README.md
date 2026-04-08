# SEEDANCE

Repositorio preparado para trabajar con el modelo Seedance mas reciente para creacion de video.

## Modelo objetivo
- Modelo oficial mas reciente: Seedance 2.0
- Fecha de lanzamiento oficial: 2026-02-12
- Estado de hosting directo en este repo: pendiente de pesos oficiales publicos

## Importante
En las fuentes oficiales revisadas no aparece descarga publica de pesos/checkpoint para autoalojar Seedance 2.0.
Por eso este repo queda listo para:
- Integracion por API/plataforma oficial
- Estructura para activar Git LFS si en el futuro publican pesos descargables

## Estructura
- `scripts/`: scripts de integracion
- `models/`: carpeta reservada para modelos/pesos
- `docs/`: notas y fuentes
- `RECUPERADO_SIDAM/`: repos y recursos comunitarios recuperados en local
- `ALTERNATIVA_LOCAL_GRATIS/`: alternativas open-source para ejecutar video IA en local

## Arranque rapido
1. Copia `.env.example` como `.env`
2. Completa tus credenciales
3. Instala dependencias:
   `pip install -r requirements.txt`
4. Ejecuta:
   `python scripts/generar_video_seedance.py "Un perro corriendo por la playa al amanecer"`

## Nota tecnica
El script incluido es un adaptador base.
Puede requerir ajuste de payload/endpoint segun la plataforma oficial que uses.

## Recuperacion local y modo gratis
- Inventario local: `docs/INVENTARIO_LOCAL_SIDAM.md`
- Plan gratis/local: `docs/PLAN_GRATIS_LOCAL_SIDAM.md`
- Estado ultima version: `docs/SEEDANCE_ULTIMA_VERSION_2026-03-20.md`
- Lanzador local: `scripts/iniciar_seedance_local.cmd`
- Icono v2.0: `brand/icono_rubencoton_seedance_v2.ico`
- Lanzador local cero: `scripts/iniciar_seedance_ruben_coton_cero.cmd`
- Regenerar inventario:
  `powershell -ExecutionPolicy Bypass -File scripts/generar_inventario_sidam.ps1`

## App local cero
- Nombre de acceso directo: `SEEDANCE RUBEN COTON.lnk`
- App local: `APP_LOCAL_CERO/app_seedance_ruben_coton.py`
- Modelo local por defecto: `THUDM/CogVideoX1.5-5B`
- URL local: `http://127.0.0.1:7860`

Nota:
- Este modo no usa API de pago externa.
- La primera ejecucion descarga pesos del modelo (archivo grande).

## CIERRE MIGRACION CLOUD

- Fecha: 2026-04-08
- Estado: preparado para retomar desde nuevo sistema


## CIERRE CLOUD 2026-04-08
- Estado: sincronizado para migracion a nuevo PC/sistema.
- Preparado para retomar desde GitHub.
- Ultima revision: 2026-04-08 15:26:05 +02:00
