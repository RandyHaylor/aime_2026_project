#!/bin/bash
set -x

MODEL=${1:?Usage: ./check_model_mounted.sh <model_path>}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODELS_FILE="$SCRIPT_DIR/models_to_mount_in_vllm.txt"

# HuggingFace models (org/name format) don't need mounting
if [[ "$MODEL" != /* ]]; then
  echo "$MODEL"
  exit 0
fi

# Verify the host path exists
if [ ! -d "$MODEL" ]; then
  echo "ERROR: Model path does not exist: $MODEL" >&2
  exit 1
fi

# Check if already in models_to_mount_in_vllm.txt
FOUND=false
while IFS= read -r line; do
  line="${line%%#*}"
  line="$(echo "$line" | xargs)"
  [ -z "$line" ] && continue
  if [ "$line" = "$MODEL" ]; then
    FOUND=true
    break
  fi
done < "$MODELS_FILE"

if [ "$FOUND" = false ]; then
  echo "$MODEL" >> "$MODELS_FILE"
  "$SCRIPT_DIR/rebuild_vllm_container.sh" >&2
fi

echo "/models/$(basename "$MODEL")"
