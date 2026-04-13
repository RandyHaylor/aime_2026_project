#!/bin/bash
./serve_model.sh /models/finetune

cd /home/aikenyon/aime_2026_project/matharena
uv run python scripts/run.py --comp aime/aime_2026 --models local/gemma4-e4b-finetune --n 1 --problems 1

read -p "Press any key to close..." -n 1
