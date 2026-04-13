#!/bin/bash
set -x

docker stop gemma4-vllm 2>/dev/null
docker rm gemma4-vllm 2>/dev/null

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/start_vllm_container.sh"
