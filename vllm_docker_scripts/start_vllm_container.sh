#!/bin/bash
set -x

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODELS_FILE="$SCRIPT_DIR/models_to_mount_in_vllm.txt"

# Already running
if docker ps --filter name=gemma4-vllm --format '{{.Names}}' | grep -q gemma4-vllm; then
  exit 0
fi

# Exists but stopped — restart it
if docker ps -a --filter name=gemma4-vllm --format '{{.Names}}' | grep -q gemma4-vllm; then
  docker start gemma4-vllm
  exit 0
fi

# Build volume mount flags from models_to_mount_in_vllm.txt
VOLUME_ARGS="-v ~/.cache/huggingface:/root/.cache/huggingface"
while IFS= read -r line; do
  line="${line%%#*}"
  line="$(echo "$line" | xargs)"
  [ -z "$line" ] && continue
  BASENAME="$(basename "$line")"
  VOLUME_ARGS="$VOLUME_ARGS -v $line:/models/$BASENAME"
done < "$MODELS_FILE"

eval docker run -d --name gemma4-vllm \
  --ipc=host \
  --network host \
  --shm-size 16G \
  --gpus all \
  --entrypoint /bin/bash \
  $VOLUME_ARGS \
  vllm/vllm-openai:gemma4 \
  -c \"sleep infinity\"
