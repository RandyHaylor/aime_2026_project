#!/bin/bash
./serve_model.sh google/gemma-4-E4B-it

cd /home/aikenyon/aime_2026_project/matharena
uv run python scripts/run.py --comp aime/aime_2026 --models local/gemma4-e4b-base --n 1

read -p "Press any key to close..." -n 1
