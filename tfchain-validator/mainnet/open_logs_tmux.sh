#/bin/bash
tmux new -d -s tfchain-validator
tmux send-keys -t tfchain-validator "docker logs tfchain-validator -f --tail 500" ENTER
