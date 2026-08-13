#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: bash test.sh INPUT_DIR [OUTPUT_MP4]" >&2
    exit 2
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
input_dir="$1"
output_path="${2:-${repo_dir}/outputs/result.mp4}"

cd "${repo_dir}"
python -m geoedit.inference \
    --input-dir "${input_dir}" \
    --output "${output_path}" \
    --tweak-index 3 \
    --tstrong-index 15 \
    --replace-mode non_hole

