#/bin/bash
tmux new -d -s tfchain_validator
tmux send-keys -t tfchain_validator "docker logs tfchain-validator -f --tail 500" ENTER
