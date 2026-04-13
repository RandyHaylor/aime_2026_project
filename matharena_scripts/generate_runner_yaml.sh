#!/bin/bash
set -x

CONTAINER_MODEL=${1:?Usage: generate_runner_yaml.sh <container_model> <human_readable_id> <max_tokens>}
HUMAN_READABLE_ID=${2:?Missing human_readable_id}
MAX_TOKENS=${3:-60000}

cat > /home/aikenyon/aime_2026_project/matharena/configs/models/local/runner.yaml <<EOF
model: $CONTAINER_MODEL
api: custom
api_key_env: null
base_url: http://localhost:8000/v1
max_tokens: $MAX_TOKENS
temperature: 0.6
concurrent_requests: 1
read_cost: 0
write_cost: 0
human_readable_id: $HUMAN_READABLE_ID
date: "2026-04-12"
EOF
