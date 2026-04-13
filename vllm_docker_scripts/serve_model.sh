#!/bin/bash
# Usage: ./serve_model.sh <model_path>
# Examples:
#   ./serve_model.sh google/gemma-4-E4B-it
#   ./serve_model.sh /models/finetune

MODEL=${1:?Usage: ./serve_model.sh <model_path>}

# Check if this model is already serving
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
  CURRENT=$(curl -s http://localhost:8000/v1/models | grep -o '"id":"[^"]*"' | head -1)
  if echo "$CURRENT" | grep -q "$(basename "$MODEL")"; then
    echo "$MODEL already serving."
    exit 0
  fi
fi

# Ensure container is running
if ! docker ps --filter name=gemma4-vllm --format '{{.Names}}' | grep -q gemma4-vllm; then
  echo "Container not running. Start it first with ./start_vllm_container.sh"
  exit 1
fi

# Kill any existing vllm server in the container
docker exec gemma4-vllm pkill -f "vllm serve" 2>/dev/null
sleep 2

# Start vllm with the requested model
docker exec -d gemma4-vllm vllm serve "$MODEL" \
  --tensor-parallel-size 1 \
  --max-model-len 65536 \
  --gpu-memory-utilization 0.90 \
  --host 0.0.0.0 \
  --port 8000

echo "Starting $MODEL..."
until curl -s http://localhost:8000/health > /dev/null 2>&1; do
  sleep 5
done
echo "vllm server ready: $MODEL"
