#!/bin/bash
# Start persistent vllm container

# Already running
if docker ps --filter name=gemma4-vllm --format '{{.Names}}' | grep -q gemma4-vllm; then
  echo "Container already running."
  exit 0
fi

# Exists but stopped — restart it
if docker ps -a --filter name=gemma4-vllm --format '{{.Names}}' | grep -q gemma4-vllm; then
  echo "Restarting existing container..."
  docker start gemma4-vllm
  echo "Container started."
  exit 0
fi

# Create new
docker run -d --name gemma4-vllm \
  --ipc=host \
  --network host \
  --shm-size 16G \
  --gpus all \
  --entrypoint /bin/bash \
  -v ~/.cache/huggingface:/root/.cache/huggingface \
  -v /home/aikenyon/ai_skills_agents_resources/self-improve-experiments/gemma4_e4b_haiku50_ep16:/models/finetune \
  vllm/vllm-openai:gemma4 \
  -c "sleep infinity"
echo "Container created. Use serve_model.sh to start serving a model."
