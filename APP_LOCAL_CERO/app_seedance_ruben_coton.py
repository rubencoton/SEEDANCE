import os
from datetime import datetime
from pathlib import Path

import gradio as gr
import torch
from diffusers import CogVideoXDPMScheduler, CogVideoXPipeline
from diffusers.utils import export_to_video


APP_TITLE = "SEEDANCE RUBEN COTON"
MODEL_ID = os.getenv("SEEDANCE_LOCAL_MODEL", "THUDM/CogVideoX1.5-5B")
DEFAULT_STEPS = int(os.getenv("SEEDANCE_LOCAL_STEPS", "28"))
OUTPUT_DIR = Path(os.getenv("SEEDANCE_LOCAL_OUTPUT_DIR", "outputs_local_cero")).resolve()

pipe = None


def _ensure_dirs() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


def _expand_prompt(user_prompt: str) -> str:
    # Prompt helper local (sin API externa) para mejorar resultados.
    base = user_prompt.strip()
    if not base:
        return ""
    return (
        "Cinematic video, coherent motion, detailed scene, natural lighting, "
        "high visual quality, smooth camera movement. "
        + base
    )


def _load_pipe() -> CogVideoXPipeline:
    global pipe
    if pipe is not None:
        return pipe

    if not torch.cuda.is_available():
        raise RuntimeError("No se detecto GPU CUDA. Esta app requiere NVIDIA CUDA.")

    dtype = torch.bfloat16
    pipe = CogVideoXPipeline.from_pretrained(MODEL_ID, torch_dtype=dtype)
    pipe.scheduler = CogVideoXDPMScheduler.from_config(
        pipe.scheduler.config, timestep_spacing="trailing"
    )

    # Modo memoria para GPUs de consumidor.
    pipe.enable_sequential_cpu_offload()
    pipe.vae.enable_slicing()
    pipe.vae.enable_tiling()

    return pipe


def _size_to_hw(size_label: str) -> tuple[int, int]:
    mapping = {
        "1360x768 (mejor calidad)": (768, 1360),
        "720x480 (mas rapido)": (480, 720),
    }
    return mapping.get(size_label, (768, 1360))


def generate_video(
    prompt: str,
    size_label: str,
    num_inference_steps: int,
    guidance_scale: float,
    seed: int,
) -> tuple[str, str]:
    _ensure_dirs()
    p = _expand_prompt(prompt)
    if not p:
        return "", "ERROR: Escribe un prompt."

    active_pipe = _load_pipe()
    height, width = _size_to_hw(size_label)

    if seed < 0:
        seed = int(datetime.utcnow().timestamp()) % 1000000007

    generator = torch.Generator(device="cpu").manual_seed(seed)
    frames = active_pipe(
        prompt=p,
        height=height,
        width=width,
        num_videos_per_prompt=1,
        num_inference_steps=num_inference_steps,
        num_frames=49,
        use_dynamic_cfg=True,
        guidance_scale=guidance_scale,
        generator=generator,
    ).frames[0]

    out_name = f"seedance_ruben_coton_{datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')}.mp4"
    out_path = OUTPUT_DIR / out_name
    export_to_video(frames, str(out_path), fps=16)

    return str(out_path), f"OK: Video creado en {out_path}"


with gr.Blocks(title=APP_TITLE) as demo:
    gr.Markdown(
        f"""
# {APP_TITLE}

- Modo: **LOCAL CERO** (sin pago por API externa)
- Motor local abierto: **{MODEL_ID}**
- Nota: primera carga tarda porque descarga pesos del modelo.
"""
    )

    with gr.Row():
        with gr.Column(scale=2):
            prompt = gr.Textbox(
                label="Prompt (mejor en ingles)",
                placeholder="A cinematic drone shot over a futuristic city at sunrise...",
                lines=4,
            )
            size_label = gr.Dropdown(
                label="Calidad / velocidad",
                choices=["1360x768 (mejor calidad)", "720x480 (mas rapido)"],
                value="720x480 (mas rapido)",
            )
            steps = gr.Slider(
                minimum=16,
                maximum=50,
                step=1,
                value=DEFAULT_STEPS,
                label="Pasos (mas = mejor, pero mas lento)",
            )
            guidance = gr.Slider(
                minimum=3.0,
                maximum=9.0,
                step=0.5,
                value=6.0,
                label="Guidance",
            )
            seed = gr.Number(value=-1, label="Seed (-1 aleatorio)")
            run_btn = gr.Button("GENERAR VIDEO LOCAL", variant="primary")

        with gr.Column(scale=2):
            video_out = gr.Video(label="Resultado")
            status = gr.Textbox(label="Estado", interactive=False)

    run_btn.click(
        fn=generate_video,
        inputs=[prompt, size_label, steps, guidance, seed],
        outputs=[video_out, status],
    )


if __name__ == "__main__":
    demo.launch(server_name="127.0.0.1", server_port=7860, share=False)
