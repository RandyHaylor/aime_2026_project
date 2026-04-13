#!/bin/bash
docker exec gemma4-vllm pkill -f "vllm serve" 2>/dev/null
docker stop gemma4-vllm 2>/dev/null
echo "Container stopped."
