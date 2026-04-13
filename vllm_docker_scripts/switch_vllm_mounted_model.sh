#!/bin/bash
set -x

MODEL=${1:?Usage: ./switch_vllm_mounted_model.sh <model_path>}

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

# Start vllm in background inside container, tailing output to host
docker exec gemma4-vllm bash -c "vllm serve '$MODEL' \
  --tensor-parallel-size 1 \
  --max-model-len 65536 \
  --gpu-memory-utilization 0.90 \
  --host 0.0.0.0 \
  --port 8000 > /tmp/vllm.log 2>&1 &"

# Tail logs from inside the container until health check passes
docker exec gemma4-vllm tail -f /tmp/vllm.log 2>/dev/null &
TAIL_PID=$!

until curl -s http://localhost:8000/health > /dev/null 2>&1; do
  # Check if vllm process is still alive
  if ! docker exec gemma4-vllm pgrep -f "vllm serve" > /dev/null 2>&1; then
    echo ""
    echo "ERROR: vllm process died. Check logs above."
    kill $TAIL_PID 2>/dev/null
    exit 1
  fi
  sleep 5
done

kill $TAIL_PID 2>/dev/null
echo "vllm server ready: $MODEL"
