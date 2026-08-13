# GeoEdit: Geometry-Aware Object Editing via Dual-Branch Denoising

Official implementation of **"GeoEdit: Geometry-Aware Object Editing via Dual-Branch Denoising"**.

[![arXiv](https://img.shields.io/badge/arXiv-2606.30003-B31B1B.svg)](https://arxiv.org/abs/2606.30003)
[![Project Page](https://img.shields.io/badge/Project-Page-blue.svg)](https://geo-edit.github.io)

## Overview

This release contains the GeoEdit denoising stage built on Wan2.2-VACE and
DiffSynth-Studio. During denoising, a reference branch is initialized at
`tweak_index`; timestep-matched reference latents are then injected through a
spatial mask until `tstrong_index`.

The repository includes the exact DiffSynth runtime used by our implementation
under `diffsynth/`. Model weights and evaluation data are not included.

## Installation

Python 3.10 or newer is required. We tested the code with PyTorch 2.5.1 and a
CUDA 12.1 runtime. Install a PyTorch build compatible with your NVIDIA driver
first, then install GeoEdit:

```bash
conda create -n geoedit python=3.10 -y
conda activate geoedit

# Example for a CUDA 12.x-compatible driver. Adjust when necessary.
pip install torch==2.5.1 torchvision==0.20.1 \
    --index-url https://download.pytorch.org/whl/cu121

pip install -e .
```

Verify CUDA before inference:

```bash
python -c "import torch; print(torch.__version__, torch.version.cuda, torch.cuda.is_available())"
```

The last value must be `True`.

## Model weights

GeoEdit uses the following ModelScope repositories:

- `PAI/Wan2.2-VACE-Fun-A14B`
- `Wan-AI/Wan2.1-T2V-1.3B` (UMT5 tokenizer)

DiffSynth downloads missing files automatically. To use an existing model
directory, set:

```bash
export DIFFSYNTH_MODEL_BASE_PATH=/path/to/models
```

The resulting layout is:

```text
models/
├── PAI/Wan2.2-VACE-Fun-A14B/
│   ├── high_noise_model/diffusion_pytorch_model.safetensors
│   ├── low_noise_model/diffusion_pytorch_model.safetensors
│   ├── models_t5_umt5-xxl-enc-bf16.pth
│   └── Wan2.1_VAE.pth
└── Wan-AI/Wan2.1-T2V-1.3B/google/umt5-xxl/
```

Set `DIFFSYNTH_SKIP_DOWNLOAD=True` only after all files are present. Model
weights are governed by their providers' licenses and are not distributed by
this repository.

## Input format

Prepare one directory per editing case. PNG images are the default input
format:

```text
case/
├── prompt.txt             # target appearance prompt
├── negative_prompt.txt    # optional
├── depth.png              # geometry control
├── first_frame.png        # reference image
├── motion_signal.png      # edited-object reference branch
├── mask.png               # new-region mask; white means foreground
└── mask_old.png           # original-object mask; required by non_hole mode
```

The default filenames are `depth.png`, `first_frame.png`,
`motion_signal.png`, `mask.png`, and `mask_old.png`. Each still image is
automatically repeated in memory to `num_frames`; no temporary MP4 files are
created.

JPG/JPEG images and video inputs (`.mp4`, `.mov`, `.avi`, `.webm`, or `.gif`)
remain supported for compatibility. Video inputs must contain at least
`num_frames` frames. The default is 81 and the value must follow `4n+1`.
Inputs are resized to the reference image size, rounded up to multiples of 16.

## Inference

The migrated batch entry point is now the path-independent `test.sh`:

```bash
bash test.sh /path/to/case outputs/result.mp4
```

The command saves both `outputs/result.mp4` and its first frame as
`outputs/result.png`.

Equivalent explicit command:

```bash
python -m geoedit.inference \
    --input-dir /path/to/case \
    --output outputs/result.mp4 \
    --tweak-index 3 \
    --tstrong-index 15 \
    --replace-mode non_hole
```

Useful options:

- `--replace-mode non_hole`: inject outside the vacated old-object hole.
- `--replace-mode mask_new`: inject only inside the new-object mask; no
  `mask_old` input is required.
- `--no-warm-start`: begin the main branch from random noise.
- `--disable-vhi` and `--initial-clean`: ablations used by the paper.
- `--vram-limit N`: explicitly limit usable GPU memory in GiB.

Run `python -m geoedit.inference --help` for the complete interface.

## Code organization

```text
geoedit/inference.py              Clean inference CLI and mask preparation
diffsynth/pipelines/wan_video.py  Dual-branch denoising and latent injection
diffsynth/                        Minimal vendored runtime required by Wan/VACE
test.sh                           Reproducible shell entry point
tests/                            Lightweight preprocessing tests
```

Experiment-only attention hooks, local batch lists, absolute paths, model
symlinks, weights, videos, outputs, and historical scripts were intentionally
excluded from this release.

## Acknowledgements and license

The code is released under the [Apache License 2.0](LICENSE). The vendored
runtime is derived from
[ModelScope DiffSynth-Studio](https://github.com/modelscope/DiffSynth-Studio);
see [NOTICE](NOTICE) for attribution and modification details.

## Citation

```bibtex
@misc{he2026geoeditgeometryawareobjectediting,
  title={GeoEdit: Geometry-Aware Object Editing via Dual-Branch Denoising},
  author={Yi He and Jiangming Wang and Xinyu Wang and Mark Fong and Songchun Zhang and Yuxuan Xue and Hai-Tao Zheng and Yue Ma},
  year={2026},
  eprint={2606.30003},
  archivePrefix={arXiv},
  primaryClass={cs.CV},
  url={https://arxiv.org/abs/2606.30003}
}
```
