#!/bin/bash
# Start persistent vllm container (run once)
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
echo "Container started. Use run_base or run_finetune scripts to serve a model."
