#!/bin/bash
# Remove and recreate the vllm container from scratch
docker stop gemma4-vllm 2>/dev/null
docker rm gemma4-vllm 2>/dev/null

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
echo "Container rebuilt."
