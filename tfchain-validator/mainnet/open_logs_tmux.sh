#/bin/bash
tmux new -d -s tfchain-mainnet-validator
tmux send-keys -t tfchain-mainnet-validator "docker logs tfchain-mainnet-validator -f --tail 500" ENTER
