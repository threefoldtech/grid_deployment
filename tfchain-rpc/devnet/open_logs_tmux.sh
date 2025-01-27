#/bin/bash
tmux new -d -s tfchain_public_rpc
tmux send-keys -t tfchain_public_rpc "docker logs tfchain-public-node -f --tail 500" ENTER
tmux new -d -s caddy
tmux send-keys -t caddy "docker logs caddy -f --tail 500" ENTER
