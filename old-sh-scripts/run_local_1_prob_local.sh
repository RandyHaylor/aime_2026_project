#!/bin/bash
# Edit this default or pass a model path as argument
DEFAULT_MODEL="/home/aikenyon/ai_skills_agents_resources/self-improve-experiments/checkpoints/grpo_ep10_merged"

MODEL=${1:-$DEFAULT_MODEL}

cat > /home/aikenyon/aime_2026_project/matharena/configs/models/local/runner.yaml <<EOF
model: $MODEL
api: custom
api_key_env: null
base_url: http://localhost:8000/v1
max_tokens: 64000
temperature: 0.6
concurrent_requests: 1
read_cost: 0
write_cost: 0
human_readable_id: $(basename "$MODEL")
date: "2026-04-12"
EOF

./serve_model.sh "$MODEL"

cd /home/aikenyon/aime_2026_project/matharena
uv run python scripts/run.py --comp aime/aime_2026 --models local/runner --n 1 --problems 1

read -p "Press any key to close..." -n 1
