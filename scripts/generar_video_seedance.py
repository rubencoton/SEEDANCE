import argparse
import json
import os
from datetime import datetime

import requests
from dotenv import load_dotenv


def build_payload(prompt: str, duration: int, resolution: str, model: str) -> dict:
    # Payload base. Ajusta llaves segun el proveedor real.
    return {
        "model": model,
        "input": {
            "text": prompt,
        },
        "video": {
            "duration_seconds": duration,
            "resolution": resolution,
        },
    }


def main() -> int:
    load_dotenv()

    parser = argparse.ArgumentParser(description="Generador base para Seedance por API")
    parser.add_argument("prompt", help="Prompt de video")
    parser.add_argument("--duration", type=int, default=8, help="Duracion en segundos")
    parser.add_argument("--resolution", default="1280x720", help="Resolucion")
    args = parser.parse_args()

    endpoint = os.getenv("SEEDANCE_API_ENDPOINT", "").strip()
    api_key = os.getenv("SEEDANCE_API_KEY", "").strip()
    model = os.getenv("SEEDANCE_MODEL", "Doubao-Seedance-2.0").strip()
    output_dir = os.getenv("SEEDANCE_OUTPUT_DIR", "outputs").strip() or "outputs"

    if not endpoint:
        raise SystemExit("Falta SEEDANCE_API_ENDPOINT en .env")
    if not api_key:
        raise SystemExit("Falta SEEDANCE_API_KEY en .env")

    payload = build_payload(args.prompt, args.duration, args.resolution, model)
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    response = requests.post(endpoint, headers=headers, json=payload, timeout=180)

    os.makedirs(output_dir, exist_ok=True)
    stamp = datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
    out_file = os.path.join(output_dir, f"seedance_response_{stamp}.json")

    with open(out_file, "w", encoding="utf-8") as f:
        try:
            f.write(json.dumps(response.json(), ensure_ascii=False, indent=2))
        except ValueError:
            f.write(response.text)

    print(f"Estado HTTP: {response.status_code}")
    print(f"Respuesta guardada en: {out_file}")

    if response.status_code >= 400:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
