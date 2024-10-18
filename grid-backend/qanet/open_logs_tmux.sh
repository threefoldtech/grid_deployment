#/bin/bash
tmux new -d -s tfchain_public_rpc
tmux send-keys -t tfchain_public_rpc "docker logs tfchain-public-node -f --tail 500" ENTER
tmux new -d -s graphql_indexer
tmux send-keys -t graphql_indexer "docker logs indexer_ingest -f --tail 500" ENTER
tmux new -d -s graphql_processor
tmux send-keys -t graphql_processor "docker logs processor -f --tail 500" ENTER
tmux new -d -s grid_relay
tmux send-keys -t grid_relay "docker logs grid_relay -f --tail 500" ENTER
tmux new -d -s grid_proxy
tmux send-keys -t grid_proxy "docker logs grid_proxy -f --tail 500" ENTER
tmux new -d -s grid_dashboard
tmux send-keys -t grid_dashboard "docker logs grid_dashboard -f --tail 500" ENTER
tmux new -d -s caddy
tmux send-keys -t caddy "docker logs caddy -f --tail 500" ENTER
