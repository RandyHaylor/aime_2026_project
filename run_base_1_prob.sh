#!/bin/bash
set -e
DEFAULT_MODEL="google/gemma-4-E4B-it"
MAX_TOKENS=60000

MODEL=${1:-$DEFAULT_MODEL}
CONTAINER_MODEL=$(./vllm_docker_scripts/check_model_mounted.sh "$MODEL") || exit 1

if ! docker ps --filter name=gemma4-vllm --format '{{.Names}}' | grep -q gemma4-vllm; then
  echo "Starting vllm container..."
  ./vllm_docker_scripts/start_vllm_container.sh
fi

./matharena_scripts/generate_runner_yaml.sh "$CONTAINER_MODEL" "$(basename "$MODEL")" "$MAX_TOKENS"
./vllm_docker_scripts/switch_vllm_mounted_model.sh "$CONTAINER_MODEL"

cd /home/aikenyon/aime_2026_project/matharena
uv run python scripts/run.py --comp aime/aime_2026 --models local/runner --n 1 --problems 1

read -p "Press any key to close..." -n 1
